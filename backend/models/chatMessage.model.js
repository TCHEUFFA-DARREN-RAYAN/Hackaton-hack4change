const { promisePool } = require('../config/database');
const { randomUUID } = require('crypto');

class ChatMessageModel {
    static async findByThread(threadId, limit = 100) {
        const [rows] = await promisePool.query(
            `SELECT m.*,
                    CASE WHEN m.sender_type = 'coordinator' THEN (SELECT CONCAT(a.first_name, ' ', a.last_name) FROM admins a WHERE a.id = m.sender_id)
                         ELSE (SELECT CONCAT(s.first_name, ' ', s.last_name) FROM staff_members s WHERE s.id = m.sender_id) END AS sender_name
             FROM chat_messages m
             WHERE m.thread_id = ?
             ORDER BY m.created_at ASC
             LIMIT ?`,
            [threadId, limit]
        );
        return rows;
    }

    static async create(data) {
        const id = randomUUID();
        const { thread_id, sender_type, sender_id, content } = data;
        await promisePool.query(
            'INSERT INTO chat_messages (id, thread_id, sender_type, sender_id, content) VALUES (?, ?, ?, ?, ?)',
            [id, thread_id, sender_type, sender_id, (content || '').trim()]
        );
        const [rows] = await promisePool.query(
            `SELECT m.*,
                    CASE WHEN m.sender_type = 'coordinator' THEN (SELECT CONCAT(a.first_name, ' ', a.last_name) FROM admins a WHERE a.id = m.sender_id)
                         ELSE (SELECT CONCAT(s.first_name, ' ', s.last_name) FROM staff_members s WHERE s.id = m.sender_id) END AS sender_name
             FROM chat_messages m WHERE m.id = ?`,
            [id]
        );
        return rows[0] || null;
    }
}

module.exports = ChatMessageModel;
