const { promisePool } = require('../config/database');
const { randomUUID } = require('crypto');

class TransferModel {
    // All available transfers from other orgs (for the claiming org)
    static async findAvailable(requestingOrgId) {
        const [rows] = await promisePool.query(
            `SELECT t.*, o.name AS from_org_name, o.address AS from_org_address, o.contact_email AS from_org_email, o.contact_phone AS from_org_phone
             FROM transfers t
             JOIN organizations o ON o.id = t.from_org_id
             WHERE t.status = 'available' AND t.from_org_id != ?
             ORDER BY t.created_at DESC`,
            [requestingOrgId]
        );
        return rows;
    }

    // Transfers offered by a specific org
    static async findByOrg(orgId) {
        const [rows] = await promisePool.query(
            `SELECT t.*,
                    fo.name AS from_org_name,
                    to_o.name AS to_org_name
             FROM transfers t
             JOIN organizations fo ON fo.id = t.from_org_id
             LEFT JOIN organizations to_o ON to_o.id = t.to_org_id
             WHERE t.from_org_id = ? OR t.to_org_id = ?
             ORDER BY t.created_at DESC`,
            [orgId, orgId]
        );
        return rows;
    }

    // All transfers — for coordinator view
    static async findAll(filters = {}) {
        let sql = `SELECT t.*,
                    fo.name AS from_org_name,
                    to_o.name AS to_org_name
                   FROM transfers t
                   JOIN organizations fo ON fo.id = t.from_org_id
                   LEFT JOIN organizations to_o ON to_o.id = t.to_org_id
                   WHERE 1=1`;
        const params = [];
        if (filters.status) { sql += ' AND t.status = ?'; params.push(filters.status); }
        sql += ' ORDER BY t.created_at DESC';
        const [rows] = await promisePool.query(sql, params);
        return rows;
    }

    static async findById(id) {
        const [rows] = await promisePool.query(
            `SELECT t.*,
                    fo.name AS from_org_name, fo.address AS from_org_address, fo.contact_email AS from_org_email,
                    to_o.name AS to_org_name
             FROM transfers t
             JOIN organizations fo ON fo.id = t.from_org_id
             LEFT JOIN organizations to_o ON to_o.id = t.to_org_id
             WHERE t.id = ? LIMIT 1`,
            [id]
        );
        return rows[0] || null;
    }

    static async create(data) {
        const id = randomUUID();
        const { from_org_id, item_name, category, quantity, unit, notes } = data;
        await promisePool.query(
            `INSERT INTO transfers (id, from_org_id, item_name, category, quantity, unit, notes)
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [id, from_org_id, item_name, category || 'goods', quantity || 1, unit || 'items', notes || null]
        );
        return this.findById(id);
    }

    static async claim(id, toOrgId) {
        await promisePool.query(
            `UPDATE transfers SET to_org_id = ?, status = 'claimed', claimed_at = NOW()
             WHERE id = ? AND status = 'available'`,
            [toOrgId, id]
        );
        return this.findById(id);
    }

    static async complete(id, orgId) {
        await promisePool.query(
            `UPDATE transfers SET status = 'completed', completed_at = NOW()
             WHERE id = ? AND (from_org_id = ? OR to_org_id = ?) AND status = 'claimed'`,
            [id, orgId, orgId]
        );
        return this.findById(id);
    }

    static async cancel(id, orgId) {
        await promisePool.query(
            `UPDATE transfers SET status = 'cancelled'
             WHERE id = ? AND from_org_id = ? AND status = 'available'`,
            [id, orgId]
        );
        return this.findById(id);
    }

    // Recent activity for coordinator dashboard
    static async findRecent(limit = 10) {
        const [rows] = await promisePool.query(
            `SELECT t.*,
                    fo.name AS from_org_name,
                    to_o.name AS to_org_name
             FROM transfers t
             JOIN organizations fo ON fo.id = t.from_org_id
             LEFT JOIN organizations to_o ON to_o.id = t.to_org_id
             ORDER BY COALESCE(t.completed_at, t.claimed_at, t.created_at) DESC
             LIMIT ?`,
            [limit]
        );
        return rows;
    }
}

module.exports = TransferModel;
