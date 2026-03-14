/**
 * Match routes — automatic donation matching (no AI required).
 * POST /api/ai/match-donation — automatic match by category, item name, urgency
 * POST /api/ai/network-insights — rule-based network summary
 */
const express = require('express');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const { authenticateToken, requireAdmin } = require('../middleware/auth.middleware');
const NeedsModel = require('../models/needs.model');
const InventoryModel = require('../models/inventory.model');
const OrganizationModel = require('../models/organization.model');

const matchLimiter = rateLimit({
    windowMs: 60 * 1000,
    max: 30,
    message: { success: false, message: 'Too many requests. Please wait a moment.' }
});

// Category similarity — map donation categories to need categories
const categoryAliases = {
    clothing: ['clothing', 'clothes'],
    bedding: ['bedding', 'bedding_linens', 'linens'],
    food: ['food', 'food_beverages', 'food_nutrition'],
    hygiene: ['hygiene'],
    baby_supplies: ['baby_supplies', 'baby'],
    goods: ['goods', 'household_goods', 'goods_essentials'],
    furniture: ['furniture'],
    other: ['other']
};

function categoryMatches(donorCat, needCat) {
    if (!donorCat || !needCat) return false;
    const d = donorCat.toLowerCase().replace(/-/g, '_');
    const n = needCat.toLowerCase().replace(/-/g, '_');
    if (d === n) return true;
    if (n.includes(d) || d.includes(n)) return true;
    const aliases = categoryAliases[d];
    return aliases ? aliases.some(a => n.includes(a) || a.includes(n)) : false;
}

function itemNameMatches(donorItem, needItem) {
    if (!donorItem || !needItem) return false;
    const d = donorItem.toLowerCase();
    const n = needItem.toLowerCase();
    if (d.includes(n) || n.includes(d)) return true;
    const dWords = d.split(/\s+/);
    const nWords = n.split(/\s+/);
    return dWords.some(w => w.length > 2 && n.includes(w)) || nWords.some(w => w.length > 2 && d.includes(w));
}

function urgencyScore(u) {
    const s = { critical: 4, high: 3, medium: 2, low: 1 };
    return s[u] || 0;
}

// POST /api/ai/match-donation — automatic matching, no AI
router.post('/match-donation', matchLimiter, async (req, res) => {
    try {
        const { item_name, category, quantity, condition } = req.body;
        if (!item_name || !category || !quantity) {
            return res.status(400).json({ success: false, message: 'item_name, category, and quantity are required' });
        }

        const needs = await NeedsModel.findAllUnfulfilled();
        if (!needs.length) {
            return res.json({ success: true, data: { matches: [], message: 'No active needs in the network right now.' } });
        }

        const scored = needs.map(n => {
            let score = 0;
            if (categoryMatches(category, n.category)) score += 10;
            if (itemNameMatches(item_name, n.item_name)) score += 15;
            score += urgencyScore(n.urgency) * 3;
            if (parseInt(quantity) >= n.quantity_needed) score += 5;
            return { need: n, score };
        }).filter(x => x.score > 0).sort((a, b) => b.score - a.score);

        const top3 = scored.slice(0, 3).map(({ need }) => ({
            org_id: need.org_id,
            org_name: need.org_name,
            org_address: need.org_address,
            org_email: need.org_email,
            urgency: need.urgency,
            reasoning: `${need.org_name} needs ${need.quantity_needed} ${need.unit} of "${need.item_name}" (${need.urgency} urgency).`
        }));

        res.json({ success: true, data: { matches: top3 } });
    } catch (err) {
        console.error('Match-donation error:', err.message);
        res.status(500).json({ success: false, message: 'Matching failed. Please try again.' });
    }
});

// POST /api/ai/network-insights — rule-based, no AI
router.post('/network-insights', authenticateToken, requireAdmin, matchLimiter, async (req, res) => {
    try {
        const orgs = await OrganizationModel.findAllWithStats();
        const needs = await NeedsModel.findAll({});
        const surplus = await InventoryModel.findAllSurplus();

        const now = Date.now();
        const staleOrgs = orgs.filter(o => {
            if (!o.last_inventory_update) return true;
            const diff = now - new Date(o.last_inventory_update).getTime();
            return diff > 48 * 60 * 60 * 1000;
        }).map(o => o.name);

        const criticalNeeds = needs.filter(n => n.urgency === 'critical');
        const surplusList = surplus.slice(0, 20);

        let summary = `Network has ${orgs.length} organizations with ${needs.length} active needs (${criticalNeeds.length} critical). `;
        summary += surplus.length > 0 ? `${surplus.length} surplus items available for redistribution. ` : '';
        summary += staleOrgs.length > 0 ? `${staleOrgs.length} organizations have not updated inventory in 48+ hours.` : 'All organizations have recent inventory updates.';

        const redistribution_opportunities = [];
        for (const s of surplusList.slice(0, 5)) {
            const match = needs.find(n => n.org_id !== s.org_id && (
                categoryMatches(s.category, n.category) || itemNameMatches(s.item_name, n.item_name)
            ));
            if (match) {
                redistribution_opportunities.push({
                    from_org: s.org_name,
                    to_org: match.org_name,
                    item: s.item_name,
                    note: `${match.org_name} needs ${match.quantity_needed} ${match.unit}.`
                });
            }
        }

        const follow_up_orgs = staleOrgs.slice(0, 3).map(org => ({
            org,
            reason: 'No inventory update in 48+ hours.'
        }));

        const alerts = [];
        if (criticalNeeds.length > 0) {
            alerts.push(`${criticalNeeds.length} critical needs require immediate attention.`);
        }
        if (staleOrgs.length > 0) {
            alerts.push(`${staleOrgs.length} organizations need inventory update follow-up.`);
        }
        if (redistribution_opportunities.length > 0) {
            alerts.push(`${redistribution_opportunities.length} surplus-to-need redistribution opportunities identified.`);
        }
        if (alerts.length === 0) {
            alerts.push('Network status is stable. No immediate alerts.');
        }

        res.json({
            success: true,
            data: {
                summary,
                redistribution_opportunities,
                follow_up_orgs,
                alerts
            }
        });
    } catch (err) {
        console.error('Network-insights error:', err.message);
        res.status(500).json({ success: false, message: 'Failed to generate insights. Please try again.' });
    }
});

module.exports = router;
