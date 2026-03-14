const mysql = require('mysql2');
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

// Aiven and other cloud MySQL require SSL
if (process.env.DB_SSL_ENABLED === 'true' || process.env.DB_SSL_ENABLED === '1') {
    let ca = process.env.DB_CA_CERT;
    if (!ca && process.env.DB_CA_CERT_PATH) {
        const certPath = path.resolve(process.cwd(), process.env.DB_CA_CERT_PATH);
        ca = fs.readFileSync(certPath, 'utf8');
    }
    dbConfig.ssl = ca
        ? { ca, rejectUnauthorized: process.env.DB_SSL_REJECT_UNAUTHORIZED !== 'false' }
        : { rejectUnauthorized: process.env.DB_SSL_REJECT_UNAUTHORIZED !== 'false' };
}

const pool = mysql.createPool(dbConfig);

const promisePool = pool.promise();

const testConnection = async () => {
    try {
        const connection = await promisePool.getConnection();
        console.log('✅ CommonGround database connected');
        connection.release();
        return true;
    } catch (error) {
        console.error('❌ Database connection failed:', error.message || error.code || String(error));
        console.error('Check: DB_HOST, DB_PORT, DB_NAME, DB_SSL_ENABLED, DB_CA_CERT_PATH, Aiven IP allowlist');
        return false;
    }
};

module.exports = { pool, promisePool, testConnection };
