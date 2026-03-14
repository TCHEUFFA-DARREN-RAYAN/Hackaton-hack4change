const { promisePool } = require('../config/database');
const { randomUUID } = require('crypto');
const { hashPassword } = require('../utils/hash.util');

class StaffModel {
    static async findByEmailForLogin(email) {
        const [rows] = await promisePool.query(
            `SELECT s.*, o.name AS org_name
             FROM staff_members s
             JOIN organizations o ON o.id = s.org_id
             WHERE LOWER(s.email) = LOWER(?) LIMIT 1`,
            [email]
        );
        return rows[0] || null;
    }

    static async findById(id) {
        const [rows] = await promisePool.query(
            `SELECT s.id, s.org_id, s.first_name, s.last_name, s.email, s.status, o.name AS org_name
             FROM staff_members s
             JOIN organizations o ON o.id = s.org_id
             WHERE s.id = ? LIMIT 1`,
            [id]
        );
        return rows[0] || null;
    }

    static async findAll(filters = {}) {
        let sql = `SELECT s.id, s.org_id, s.first_name, s.last_name, s.email, s.status, s.created_at, o.name AS org_name
                   FROM staff_members s
                   JOIN organizations o ON o.id = s.org_id
                   WHERE 1=1`;
        const params = [];
        if (filters.org_id) {
            sql += ' AND s.org_id = ?';
            params.push(filters.org_id);
        }
        sql += ' ORDER BY o.name ASC, s.last_name ASC, s.first_name ASC';
        const [rows] = await promisePool.query(sql, params);
        return rows;
    }

    static async create(data) {
        const id = randomUUID();
        const { org_id, first_name, last_name, email, password } = data;
        if (!org_id || !first_name || !last_name || !email || !password) {
            throw new Error('org_id, first_name, last_name, email, and password are required');
        }
        const password_hash = await hashPassword(password);
        await promisePool.query(
            `INSERT INTO staff_members (id, org_id, first_name, last_name, email, password_hash)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [id, org_id, first_name.trim(), last_name.trim(), email.trim().toLowerCase(), password_hash]
        );
        return this.findById(id);
    }

    static async update(id, data) {
        const allowed = ['first_name', 'last_name', 'email'];
        const set = [];
        const vals = [];
        for (const k of allowed) {
            if (data[k] !== undefined) {
                set.push(`${k} = ?`);
                let v = typeof data[k] === 'string' ? data[k].trim() : data[k];
                if (k === 'email') v = v.toLowerCase();
                vals.push(v);
            }
        }
        if (set.length === 0) return this.findById(id);
        vals.push(id);
        await promisePool.query(`UPDATE staff_members SET ${set.join(', ')} WHERE id = ?`, vals);
        return this.findById(id);
    }

    static async updateStatus(id, status) {
        if (!['active', 'inactive'].includes(status)) {
            throw new Error('Invalid status');
        }
        const [result] = await promisePool.query(
            'UPDATE staff_members SET status = ? WHERE id = ?',
            [status, id]
        );
        if (result.affectedRows === 0) return null;
        return this.findById(id);
    }

    static async delete(id) {
        const [result] = await promisePool.query('DELETE FROM staff_members WHERE id = ?', [id]);
        return result.affectedRows > 0;
    }
}

module.exports = StaffModel;
