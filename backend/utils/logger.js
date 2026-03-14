/**
 * Structured logger for production.
 * In production, outputs JSON for log aggregation.
 */
const isProd = process.env.NODE_ENV === 'production';

function log(level, message, meta = {}) {
    const entry = {
        level,
        message,
        timestamp: new Date().toISOString(),
        ...meta
    };
    if (isProd) {
        console.log(JSON.stringify(entry));
    } else {
        const prefix = `[${entry.timestamp}] ${level.toUpperCase()}:`;
        if (Object.keys(meta).length) {
            console[level === 'error' ? 'error' : 'log'](prefix, message, meta);
        } else {
            console[level === 'error' ? 'error' : 'log'](prefix, message);
        }
    }
}

module.exports = {
    info: (msg, meta) => log('info', msg, meta),
    warn: (msg, meta) => log('warn', msg, meta),
    error: (msg, meta) => log('error', msg, meta)
};
