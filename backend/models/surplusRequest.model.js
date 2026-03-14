const { promisePool } = require('../config/database');
const { randomUUID } = require('crypto');

class SurplusRequestModel {
    static async create(data) {
        const id = randomUUID();
        const { requesting_org_id, from_org_id, inventory_item_id, quantity_requested, notes } = data;
        await promisePool.query(
            `INSERT INTO surplus_requests (id, requesting_org_id, from_org_id, inventory_item_id, quantity_requested, notes)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [id, requesting_org_id, from_org_id, inventory_item_id, quantity_requested || 1, notes || null]
        );
        return this.findById(id);
    }

    static async findById(id) {
        const [rows] = await promisePool.query(
            `SELECT sr.*, 
                    o_from.name AS from_org_name, o_to.name AS requesting_org_name,
                    i.item_name, i.category, i.quantity AS available_quantity, i.unit
             FROM surplus_requests sr
             JOIN organizations o_from ON o_from.id = sr.from_org_id
             JOIN organizations o_to ON o_to.id = sr.requesting_org_id
             JOIN inventory_items i ON i.id = sr.inventory_item_id
             WHERE sr.id = ? LIMIT 1`,
            [id]
        );
        return rows[0] || null;
    }

    static async findByRequestingOrg(orgId, status) {
        let sql = `SELECT sr.*, o_from.name AS from_org_name, i.item_name, i.category, i.unit
                   FROM surplus_requests sr
                   JOIN organizations o_from ON o_from.id = sr.from_org_id
                   JOIN inventory_items i ON i.id = sr.inventory_item_id
                   WHERE sr.requesting_org_id = ?`;
        const params = [orgId];
        if (status) {
            sql += ' AND sr.status = ?';
            params.push(status);
        }
        sql += ' ORDER BY sr.created_at DESC';
        const [rows] = await promisePool.query(sql, params);
        return rows;
    }

    static async findByFromOrg(orgId) {
        const [rows] = await promisePool.query(
            `SELECT sr.*, o_to.name AS requesting_org_name, i.item_name, i.category, i.unit
             FROM surplus_requests sr
             JOIN organizations o_to ON o_to.id = sr.requesting_org_id
             JOIN inventory_items i ON i.id = sr.inventory_item_id
             WHERE sr.from_org_id = ?
             ORDER BY sr.created_at DESC`,
            [orgId]
        );
        return rows;
    }

    static async findAllPending() {
        const [rows] = await promisePool.query(
            `SELECT sr.*, o_from.name AS from_org_name, o_to.name AS requesting_org_name,
                    i.item_name, i.category, i.quantity AS available_quantity, i.unit
             FROM surplus_requests sr
             JOIN organizations o_from ON o_from.id = sr.from_org_id
             JOIN organizations o_to ON o_to.id = sr.requesting_org_id
             JOIN inventory_items i ON i.id = sr.inventory_item_id
             WHERE sr.status = 'pending'
             ORDER BY sr.created_at ASC`
        );
        return rows;
    }

    static async updateStatus(id, status) {
        const allowed = ['approved', 'rejected', 'completed'];
        if (!allowed.includes(status)) return null;
        const field = status === 'completed' ? 'completed_at' : 'responded_at';
        await promisePool.query(
            `UPDATE surplus_requests SET status = ?, ${field} = NOW() WHERE id = ?`,
            [status, id]
        );
        return this.findById(id);
    }
}

module.exports = SurplusRequestModel;
