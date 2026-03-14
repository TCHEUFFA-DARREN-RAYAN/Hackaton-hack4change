const { promisePool } = require('../config/database');
const { randomUUID } = require('crypto');

class SurplusTransferModel {
    static async create(data) {
        const id = randomUUID();
        const { from_org_id, to_org_id, inventory_item_id, quantity, coordinator_notes } = data;
        await promisePool.query(
            `INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, coordinator_notes)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [id, from_org_id, to_org_id, inventory_item_id, quantity || 1, coordinator_notes || null]
        );
        return this.findById(id);
    }

    static async findById(id) {
        const [rows] = await promisePool.query(
            `SELECT st.*, o_from.name AS from_org_name, o_to.name AS to_org_name,
                    i.item_name, i.category, i.unit
             FROM surplus_transfers st
             JOIN organizations o_from ON o_from.id = st.from_org_id
             JOIN organizations o_to ON o_to.id = st.to_org_id
             JOIN inventory_items i ON i.id = st.inventory_item_id
             WHERE st.id = ? LIMIT 1`,
            [id]
        );
        return rows[0] || null;
    }

    static async findByToOrg(orgId) {
        const [rows] = await promisePool.query(
            `SELECT st.*, o_from.name AS from_org_name, i.item_name, i.category, i.unit
             FROM surplus_transfers st
             JOIN organizations o_from ON o_from.id = st.from_org_id
             JOIN inventory_items i ON i.id = st.inventory_item_id
             WHERE st.to_org_id = ?
             ORDER BY st.created_at DESC`,
            [orgId]
        );
        return rows;
    }

    static async findByFromOrg(orgId) {
        const [rows] = await promisePool.query(
            `SELECT st.*, o_to.name AS to_org_name, i.item_name, i.category, i.unit
             FROM surplus_transfers st
             JOIN organizations o_to ON o_to.id = st.to_org_id
             JOIN inventory_items i ON i.id = st.inventory_item_id
             WHERE st.from_org_id = ?
             ORDER BY st.created_at DESC`,
            [orgId]
        );
        return rows;
    }

    static async findAll(filters = {}) {
        let sql = `SELECT st.*, o_from.name AS from_org_name, o_to.name AS to_org_name,
                          i.item_name, i.category, i.unit
                   FROM surplus_transfers st
                   JOIN organizations o_from ON o_from.id = st.from_org_id
                   JOIN organizations o_to ON o_to.id = st.to_org_id
                   JOIN inventory_items i ON i.id = st.inventory_item_id
                   WHERE 1=1`;
        const params = [];
        if (filters.status) {
            sql += ' AND st.status = ?';
            params.push(filters.status);
        }
        sql += ' ORDER BY st.created_at DESC';
        const [rows] = await promisePool.query(sql, params);
        return rows;
    }

    static async updateStatus(id, status) {
        const allowed = ['in_transit', 'completed', 'cancelled'];
        if (!allowed.includes(status)) return null;
        const updates = status === 'completed' ? ', completed_at = NOW()' : '';
        await promisePool.query(
            `UPDATE surplus_transfers SET status = ? ${updates} WHERE id = ?`,
            [status, id]
        );
        return this.findById(id);
    }
}

module.exports = SurplusTransferModel;
