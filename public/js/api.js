// CommonGround — API client
const API_BASE = '/api';

async function api(path, options = {}) {
    const res = await fetch(API_BASE + path, {
        ...options,
        credentials: 'include',
        headers: { 'Content-Type': 'application/json', ...options.headers }
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw Object.assign(new Error(data.message || 'Request failed'), { status: res.status, data });
    return data;
}

const auth = {
    me:     ()              => api('/auth/me'),
    login:  (email, password, role) => api('/auth/login',  { method: 'POST', body: JSON.stringify({ email, password, role }) }),
    logout: ()              => api('/auth/logout', { method: 'POST' }),
    refresh: ()             => api('/auth/refresh', { method: 'POST' })
};

const pub = {
    orgsWithNeeds: ()       => api('/public/orgs-with-needs'),
    needs:  (params = {})   => api('/public/needs?' + new URLSearchParams(params)),
    organizations: ()       => api('/public/organizations'),
    submitDonation: (data)  => api('/public/donations', { method: 'POST', body: JSON.stringify(data) }),
    applyMatch: (id, orgId, reasoning) =>
        api(`/public/donations/${id}/match`, { method: 'PATCH', body: JSON.stringify({ org_id: orgId, reasoning }) })
};

const staff = {
    org:                  ()        => api('/staff/org'),
    inventory:            ()        => api('/staff/inventory'),
    addInventory:         (data)    => api('/staff/inventory',      { method: 'POST',  body: JSON.stringify(data) }),
    updateInventory:      (id, data)=> api(`/staff/inventory/${id}`,{ method: 'PATCH', body: JSON.stringify(data) }),
    deleteInventory:      (id)      => api(`/staff/inventory/${id}`,{ method: 'DELETE' }),
    needs:                ()        => api('/staff/needs'),
    addNeed:              (data)    => api('/staff/needs',          { method: 'POST',  body: JSON.stringify(data) }),
    updateNeed:           (id, data)=> api(`/staff/needs/${id}`,    { method: 'PATCH', body: JSON.stringify(data) }),
    fulfillNeed:          (id)      => api(`/staff/needs/${id}/fulfill`, { method: 'POST' }),
    deleteNeed:           (id)      => api(`/staff/needs/${id}`,    { method: 'DELETE' }),
    donations:            ()        => api('/staff/donations'),
    confirmDonation:      (id)      => api(`/staff/donations/${id}/confirm`, { method: 'POST' }),
    surplus:              ()        => api('/staff/surplus'),
    surplusRequests:      ()        => api('/staff/surplus-requests'),
    requestSurplus:       (data)    => api('/staff/surplus-requests', { method: 'POST', body: JSON.stringify(data) }),
    transfers:            ()        => api('/staff/transfers'),
    completeTransfer:     (id)      => api(`/staff/transfers/${id}/complete`, { method: 'POST' }),
    expiring:             (days)    => api('/staff/expiring?' + new URLSearchParams(days ? { days } : {}))
};

const coordinator = {
    overview:             ()        => api('/coordinator/overview'),
    orgs:                 ()        => api('/coordinator/orgs'),
    createOrg:             (data)    => api('/coordinator/orgs', { method: 'POST', body: JSON.stringify(data) }),
    updateOrg:             (id, data)=> api(`/coordinator/orgs/${id}`, { method: 'PATCH', body: JSON.stringify(data) }),
    staff:                (params)  => api('/coordinator/staff?' + new URLSearchParams(params || {})),
    createStaff:          (data)    => api('/coordinator/staff', { method: 'POST', body: JSON.stringify(data) }),
    updateStaff:          (id, data)=> api(`/coordinator/staff/${id}`, { method: 'PATCH', body: JSON.stringify(data) }),
    deleteStaff:          (id)      => api(`/coordinator/staff/${id}`, { method: 'DELETE' }),
    needs:                (params)  => api('/coordinator/needs?' + new URLSearchParams(params || {})),
    donations:            (params)  => api('/coordinator/donations?' + new URLSearchParams(params || {})),
    updateDonationStatus: (id, status) => api(`/coordinator/donations/${id}/status`, { method: 'PATCH', body: JSON.stringify({ status }) }),
    inventory:            (params)  => api('/coordinator/inventory?' + new URLSearchParams(params || {})),
    surplus:              ()        => api('/coordinator/surplus'),
    expiring:             (days)   => api('/coordinator/expiring?' + new URLSearchParams(days ? { days } : {})),
    surplusRequests:      (status)  => api('/coordinator/surplus-requests?' + new URLSearchParams(status ? { status } : {})),
    updateSurplusRequest:  (id, status) => api(`/coordinator/surplus-requests/${id}`, { method: 'PATCH', body: JSON.stringify({ status }) }),
    transfers:            (params) => api('/coordinator/transfers?' + new URLSearchParams(params || {})),
    createTransfer:       (data)   => api('/coordinator/transfers', { method: 'POST', body: JSON.stringify(data) }),
    updateTransferStatus: (id, status) => api(`/coordinator/transfers/${id}/status`, { method: 'PATCH', body: JSON.stringify({ status }) }),
    exportNeeds:          ()        => window.open('/api/coordinator/export/needs'),
    exportInventory:      ()        => window.open('/api/coordinator/export/inventory')
};

const aiApi = {
    matchDonation:   (data)  => api('/ai/match-donation',    { method: 'POST', body: JSON.stringify(data) }),
    networkInsights: ()      => api('/ai/network-insights',  { method: 'POST' })
};
