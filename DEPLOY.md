# Deploying CommonGround to Render + Aiven

## 1. Aiven (MySQL Database)

### Create MySQL service
1. Sign up at [aiven.io](https://aiven.io)
2. Create a new **MySQL** service
3. Choose region close to Render (e.g. `aws-us-east-1`)
4. Note the connection details from the service overview

### Connection details
Aiven provides:
- **Host** — e.g. `your-service-name.aivencloud.com`
- **Port** — often `22013` (not 3306)
- **User** — usually `avnadmin`
- **Password** — set when creating the service
- **Database** — default is `defaultdb` or create one

### SSL
Aiven MySQL requires SSL. The app uses `DB_SSL_ENABLED=true` to enable it.

Optional: Download the CA certificate from Aiven’s service page and set `DB_CA_CERT` to its contents (for stricter validation).

### Network access
In Aiven, ensure your MySQL service allows connections from Render. Either add Render egress IPs to the allowlist, or use "Allow access from anywhere" (0.0.0.0/0) for development/demo.

---

## 2. Render (Web Service)

### Create Web Service
1. Push your code to GitHub
2. In [Render](https://render.com), **New → Web Service**
3. Connect the GitHub repo
4. Configure:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Instance Type:** Free or paid

### Environment variables
Set these in Render’s **Environment** tab:

| Variable | Value |
|----------|-------|
| `NODE_ENV` | `production` |
| `PORT` | `3000` (Render sets this automatically; keep for local) |
| `DB_HOST` | Your Aiven host (e.g. `xxx.aivencloud.com`) |
| `DB_PORT` | Aiven port (e.g. `22013`) |
| `DB_USER` | Aiven user (e.g. `avnadmin`) |
| `DB_PASSWORD` | Aiven password |
| `DB_NAME` | Database name (e.g. `defaultdb` or `commonground`) |
| `DB_SSL_ENABLED` | `true` |
| `JWT_SECRET` | Long random string (e.g. `openssl rand -hex 32`) |
| `COOKIE_SECURE` | `true` |
| `COOKIE_SECRET` | Random string for signed cookies (e.g. `openssl rand -hex 32`) |
| `CORS_ORIGINS` | Your Render URL (e.g. `https://your-app.onrender.com`) |
| `ADMIN_DEFAULT_EMAIL` | `coordinator@gmhsc.ca` |
| `ADMIN_DEFAULT_PASSWORD` | Strong password for coordinator |

### Optional
- `DB_CA_CERT` — Paste Aiven CA cert content if you use a custom CA

---

## 3. Run migration

Aiven starts with an empty database. Run the migration once:

**Option A — From your machine**
```bash
# Set env vars to match Aiven, then:
npm run migrate
```

**Option B — Render shell**
1. In Render dashboard → your service → **Shell**
2. Run: `npm run migrate`

**Option C — One-off job**
Create a one-off job in Render that runs `npm run migrate` with the same env vars.

---

## 4. Checklist

- [ ] Aiven MySQL service created
- [ ] Database created (or using `defaultdb`)
- [ ] Render Web Service created and connected to GitHub
- [ ] All env vars set in Render (especially `DB_*` and `DB_SSL_ENABLED=true`)
- [ ] `CORS_ORIGINS` includes your Render URL
- [ ] `COOKIE_SECURE=true` for HTTPS
- [ ] Migration run successfully
- [ ] App starts and connects to database

---

## 5. Troubleshooting

**"Database connection failed" (most common: Aiven IP allowlist)**
1. **Aiven IP allowlist** — In Aiven dashboard → your MySQL service → Settings → "Allowed IP addresses". Add `0.0.0.0/0` to allow connections from anywhere (Render uses dynamic IPs). Without this, Render cannot connect.
2. Check `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` are set in Render Environment
3. Use `DB_NAME=defaultdb` (Aiven's default) unless you created another database
4. Ensure `DB_SSL_ENABLED=true` and `DB_CA_CERT_PATH=ca.pem`

**"SSL connection error"**
- Set `DB_SSL_ENABLED=true`
- If needed, add Aiven’s CA cert to `DB_CA_CERT`

**CORS errors**
- Add your Render URL to `CORS_ORIGINS` (e.g. `https://commonground-xxx.onrender.com`)

**Cookies not persisting**
- Set `COOKIE_SECURE=true` for HTTPS
- Ensure `CORS_ORIGINS` includes the exact frontend origin and `credentials: true` is used
