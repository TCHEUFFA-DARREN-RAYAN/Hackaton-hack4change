/**
 * Coordinator routes — requires coordinator role.
 * Full network visibility: all orgs, all donations, all needs.
 */
const express = require('express');
const router = express.Router();
const { authenticateToken, requireAdmin } = require('../middleware/auth.middleware');
const OrganizationModel = require('../models/organization.model');
const StaffModel = require('../models/staff.model');
const NeedsModel = require('../models/needs.model');
const InventoryModel = require('../models/inventory.model');
const DonationModel = require('../models/donation.model');
const SurplusRequestModel = require('../models/surplusRequest.model');
const SurplusTransferModel = require('../models/surplusTransfer.model');
const { promisePool } = require('../config/database');

router.use(authenticateToken, requireAdmin);

// GET /api/coordinator/overview — network stats for dashboard header
router.get('/overview', async (req, res) => {
    try {
        const [orgCount] = await promisePool.query(`SELECT COUNT(*) AS total FROM organizations`);
        const [needsCount] = await promisePool.query(`SELECT COUNT(*) AS total FROM needs WHERE fulfilled = 0`);
        const [criticalCount] = await promisePool.query(`SELECT COUNT(*) AS total FROM needs WHERE fulfilled = 0 AND urgency = 'critical'`);
        const [expiringCount] = await promisePool.query(
            `SELECT COUNT(*) AS total FROM inventory_items 
             WHERE expiry_date IS NOT NULL AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) AND expiry_date >= CURDATE()`
        );
        const pipeline = await DonationModel.getPipelineCounts();

        res.json({
            success: true,
            data: {
                total_orgs: orgCount[0].total,
                active_needs: needsCount[0].total,
                critical_needs: criticalCount[0].total,
                expiring_soon: expiringCount[0].total,
                donations: pipeline
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load overview' });
    }
});

// GET /api/coordinator/orgs — all orgs with stats
router.get('/orgs', async (req, res) => {
    try {
        const orgs = await OrganizationModel.findAllWithStats();
        res.json({ success: true, data: orgs });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load organizations' });
    }
});

router.post('/orgs', async (req, res) => {
    try {
        const org = await OrganizationModel.create(req.body);
        res.status(201).json({ success: true, data: org });
    } catch (err) {
        console.error(err);
        res.status(400).json({ success: false, message: err.message || 'Failed to create organization' });
    }
});

router.patch('/orgs/:id', async (req, res) => {
    try {
        const org = await OrganizationModel.update(req.params.id, req.body);
        if (!org) return res.status(404).json({ success: false, message: 'Organization not found' });
        res.json({ success: true, data: org });
    } catch (err) {
        console.error(err);
        res.status(400).json({ success: false, message: err.message || 'Failed to update organization' });
    }
});

// Staff management
router.get('/staff', async (req, res) => {
    try {
        const { org_id } = req.query;
        const staff = await StaffModel.findAll({ org_id: org_id || undefined });
        res.json({ success: true, data: staff });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load staff' });
    }
});

router.post('/staff', async (req, res) => {
    try {
        const { org_id, first_name, last_name, email, password } = req.body;
        if (!org_id || !first_name || !last_name || !email || !password) {
            return res.status(400).json({ success: false, message: 'org_id, first_name, last_name, email, and password are required' });
        }
        const staff = await StaffModel.create({ org_id, first_name, last_name, email, password });
        res.status(201).json({ success: true, data: staff });
    } catch (err) {
        console.error(err);
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ success: false, message: 'Email already in use' });
        }
        res.status(500).json({ success: false, message: err.message || 'Failed to create staff' });
    }
});

router.patch('/staff/:id', async (req, res) => {
    try {
        const { first_name, last_name, email, status } = req.body;
        if (status !== undefined) {
            const updated = await StaffModel.updateStatus(req.params.id, status);
            if (!updated) return res.status(404).json({ success: false, message: 'Staff not found' });
            return res.json({ success: true, data: updated });
        }
        const updates = {};
        if (first_name !== undefined) updates.first_name = first_name;
        if (last_name !== undefined) updates.last_name = last_name;
        if (email !== undefined) updates.email = email;
        if (Object.keys(updates).length === 0) {
            const staff = await StaffModel.findById(req.params.id);
            if (!staff) return res.status(404).json({ success: false, message: 'Staff not found' });
            return res.json({ success: true, data: staff });
        }
        const staff = await StaffModel.update(req.params.id, updates);
        if (!staff) return res.status(404).json({ success: false, message: 'Staff not found' });
        res.json({ success: true, data: staff });
    } catch (err) {
        console.error(err);
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ success: false, message: 'Email already in use' });
        }
        res.status(500).json({ success: false, message: err.message || 'Failed to update staff' });
    }
});

router.delete('/staff/:id', async (req, res) => {
    try {
        const deleted = await StaffModel.delete(req.params.id);
        if (!deleted) return res.status(404).json({ success: false, message: 'Staff not found' });
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to delete staff' });
    }
});

// GET /api/coordinator/needs — all needs across network
router.get('/needs', async (req, res) => {
    try {
        const { urgency, category, search } = req.query;
        const needs = await NeedsModel.findAll({ urgency, category, search });
        res.json({ success: true, data: needs });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load needs' });
    }
});

// GET /api/coordinator/donations — full donations pipeline
router.get('/donations', async (req, res) => {
    try {
        const { status } = req.query;
        const donations = await DonationModel.findAll({ status });
        res.json({ success: true, data: donations });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load donations' });
    }
});

// PATCH /api/coordinator/donations/:id/status
router.patch('/donations/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        const donation = await DonationModel.updateStatus(req.params.id, status);
        if (!donation) return res.status(404).json({ success: false, message: 'Donation not found or invalid status' });
        res.json({ success: true, data: donation });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to update donation' });
    }
});

// GET /api/coordinator/inventory — all inventory across orgs (with filters)
router.get('/inventory', async (req, res) => {
    try {
        const { org_id, status, category, search } = req.query;
        let sql = `SELECT i.*, o.name AS org_name
                   FROM inventory_items i
                   JOIN organizations o ON o.id = i.org_id
                   WHERE 1=1`;
        const params = [];
        if (org_id) {
            sql += ' AND i.org_id = ?';
            params.push(org_id);
        }
        if (status) {
            sql += ' AND i.status = ?';
            params.push(status);
        }
        if (category) {
            sql += ' AND i.category = ?';
            params.push(category);
        }
        if (search && search.trim()) {
            sql += ' AND (i.item_name LIKE ? OR i.category LIKE ?)';
            const term = '%' + search.trim() + '%';
            params.push(term, term);
        }
        sql += ' ORDER BY o.name ASC, i.item_name ASC';
        const [rows] = await promisePool.query(sql, params);
        res.json({ success: true, data: rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load inventory' });
    }
});

// GET /api/coordinator/surplus — all surplus inventory items for matching
router.get('/surplus', async (req, res) => {
    try {
        const items = await InventoryModel.findAllSurplus();
        res.json({ success: true, data: items });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load surplus' });
    }
});

// GET /api/coordinator/expiring — items expiring soon (7–30 days)
router.get('/expiring', async (req, res) => {
    try {
        const days = parseInt(req.query.days) || 30;
        const items = await InventoryModel.findExpiringSoon(days);
        res.json({ success: true, data: items });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load expiring items' });
    }
});

// Surplus requests (staff-initiated)
router.get('/surplus-requests', async (req, res) => {
    try {
        const status = req.query.status || 'pending';
        const [rows] = await promisePool.query(
            `SELECT sr.*, o_from.name AS from_org_name, o_to.name AS requesting_org_name,
                    i.item_name, i.category, i.quantity AS available_quantity, i.unit
             FROM surplus_requests sr
             JOIN organizations o_from ON o_from.id = sr.from_org_id
             JOIN organizations o_to ON o_to.id = sr.requesting_org_id
             JOIN inventory_items i ON i.id = sr.inventory_item_id
             WHERE sr.status = ?
             ORDER BY sr.created_at ASC`,
            [status]
        );
        res.json({ success: true, data: rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load surplus requests' });
    }
});

router.patch('/surplus-requests/:id', async (req, res) => {
    try {
        const { status } = req.body;
        if (!['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status' });
        }
        const request = await SurplusRequestModel.updateStatus(req.params.id, status);
        if (!request) return res.status(404).json({ success: false, message: 'Request not found' });
        res.json({ success: true, data: request });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to update request' });
    }
});

// Surplus transfers (coordinator-initiated)
router.get('/transfers', async (req, res) => {
    try {
        const transfers = await SurplusTransferModel.findAll(req.query);
        res.json({ success: true, data: transfers });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to load transfers' });
    }
});

router.post('/transfers', async (req, res) => {
    try {
        const { from_org_id, to_org_id, inventory_item_id, quantity, coordinator_notes } = req.body;
        if (!from_org_id || !to_org_id || !inventory_item_id) {
            return res.status(400).json({ success: false, message: 'from_org_id, to_org_id, and inventory_item_id are required' });
        }
        const item = await InventoryModel.findById(inventory_item_id);
        if (!item || item.org_id !== from_org_id) {
            return res.status(400).json({ success: false, message: 'Invalid surplus item' });
        }
        const qty = Math.min(parseInt(quantity) || 1, item.quantity);
        const transfer = await SurplusTransferModel.create({
            from_org_id,
            to_org_id,
            inventory_item_id,
            quantity: qty,
            coordinator_notes
        });
        res.status(201).json({ success: true, data: transfer });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to create transfer' });
    }
});

router.patch('/transfers/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        if (!['in_transit', 'completed', 'cancelled'].includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status' });
        }
        const transfer = await SurplusTransferModel.updateStatus(req.params.id, status);
        if (!transfer) return res.status(404).json({ success: false, message: 'Transfer not found' });
        res.json({ success: true, data: transfer });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Failed to update transfer' });
    }
});

// GET /api/coordinator/export/needs — CSV export
router.get('/export/needs', async (req, res) => {
    try {
        const needs = await NeedsModel.findAll({});
        const header = 'Organization,Item,Category,Quantity Needed,Unit,Urgency,Notes,Posted\n';
        const rows = needs.map(n =>
            [n.org_name, n.item_name, n.category, n.quantity_needed, n.unit, n.urgency,
                (n.notes || '').replace(/,/g, ';'), new Date(n.created_at).toLocaleDateString('en-CA')]
            .join(',')
        ).join('\n');
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', 'attachment; filename="gmhsc-needs.csv"');
        res.send(header + rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Export failed' });
    }
});

// GET /api/coordinator/export/inventory — CSV export
router.get('/export/inventory', async (req, res) => {
    try {
        const [items] = await promisePool.query(
            `SELECT o.name AS org_name, i.item_name, i.category, i.quantity, i.unit, i.status, i.expiry_date, i.updated_at
             FROM inventory_items i JOIN organizations o ON o.id = i.org_id ORDER BY o.name, i.item_name`
        );
        const header = 'Organization,Item,Category,Quantity,Unit,Status,Expiry,Last Updated\n';
        const rows = items.map(i =>
            [i.org_name, i.item_name, i.category, i.quantity, i.unit, i.status,
                i.expiry_date ? new Date(i.expiry_date).toLocaleDateString('en-CA') : '',
                new Date(i.updated_at).toLocaleDateString('en-CA')]
            .join(',')
        ).join('\n');
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', 'attachment; filename="gmhsc-inventory.csv"');
        res.send(header + rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Export failed' });
    }
});

module.exports = router;
