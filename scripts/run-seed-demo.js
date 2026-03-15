/**
 * Run seed-demo.sql against the database using project config.
 * Usage: node scripts/run-seed-demo.js
 */
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const mysql = require('mysql2/promise');

const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT || '3306', 10),
    multipleStatements: true
};

if (process.env.DB_SSL_ENABLED === 'true' || process.env.DB_SSL_ENABLED === '1') {
    const certPath = path.resolve(__dirname, '../ca.pem');
    if (fs.existsSync(certPath)) {
        dbConfig.ssl = { ca: fs.readFileSync(certPath, 'utf8') };
    }
}

async function run() {
    const sqlPath = path.join(__dirname, '../seed-demo.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('Connecting to database...');
    const conn = await mysql.createConnection(dbConfig);
    console.log('Running seed-demo.sql...');

    try {
        await conn.query(sql);
        console.log('✅ Seed completed successfully.');
    } catch (err) {
        console.error('❌ Seed failed:', err.message);
        process.exit(1);
    } finally {
        await conn.end();
    }
}

run();
