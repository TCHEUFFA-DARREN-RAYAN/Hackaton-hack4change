-- ============================================================
-- CommonGround — DEMO SEED SCRIPT
-- ============================================================
-- Clears the entire database and fills with realistic demo data
-- based on real Moncton NB organizations.
--
-- Coordinator login : coordinator@commonground.ca / password123
-- Staff logins      : <org email from organizations.json> / password123
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE chat_messages;
TRUNCATE TABLE chat_threads;
TRUNCATE TABLE surplus_transfers;
TRUNCATE TABLE surplus_requests;
TRUNCATE TABLE donations;
TRUNCATE TABLE inventory_items;
TRUNCATE TABLE needs;
TRUNCATE TABLE staff_members;
TRUNCATE TABLE organizations;
TRUNCATE TABLE admins;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- UUIDs
-- ============================================================
SET @admin_id  = UUID();

SET @org1  = UUID(); -- House of Nazareth
SET @org2  = UUID(); -- Harvest House Atlantic
SET @org3  = UUID(); -- Crossroads for Women
SET @org4  = UUID(); -- YWCA Moncton
SET @org5  = UUID(); -- John Howard Society of SE NB
SET @org6  = UUID(); -- Peter McKee Community Food Centre
SET @org7  = UUID(); -- Second Mile Food Bank
SET @org8  = UUID(); -- Salvation Army Community Services
SET @org9  = UUID(); -- St. Vincent de Paul Society
SET @org10 = UUID(); -- The Humanity Project

SET @staff1  = UUID();
SET @staff2  = UUID();
SET @staff3  = UUID();
SET @staff4  = UUID();
SET @staff5  = UUID();
SET @staff6  = UUID();
SET @staff7  = UUID();
SET @staff8  = UUID();
SET @staff9  = UUID();
SET @staff10 = UUID();

-- ============================================================
-- COORDINATOR (admin)
-- Email: coordinator@commonground.ca | Password: password123
-- ============================================================
INSERT INTO admins (id, first_name, last_name, email, password_hash, role, status)
VALUES (
    @admin_id,
    'Sarah',
    'Mitchell',
    'coordinator@commonground.ca',
    '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm',
    'coordinator',
    'active'
);

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
INSERT INTO organizations (id, name, category, address, contact_email, contact_phone, website, notes) VALUES
(@org1,  'House of Nazareth',                 'shelter_housing',  '75 Albert St, Moncton, NB E1C 1B9',           'info@maisonnazareth.ca',             '506-858-5702', 'https://maisonnazareth.ca',         'Emergency shelter for men, women, and families. 42-bed capacity with 24/7 intake.'),
(@org2,  'Harvest House Atlantic',            'shelter_housing',  '182 High St, Moncton, NB E1C 6A7',            'info@harvesthouseatlantic.org',      '506-388-4357', 'https://harvesthouseatlantic.org',  'Emergency shelter and transitional housing program serving men and women.'),
(@org3,  'Crossroads for Women',              'shelter_housing',  'Moncton, NB (confidential address)',           'adminfo@crossroadsforwomen.ca',      '506-853-0811', 'https://crossroadsforwomen.ca',     'Transition shelter for women and children fleeing domestic violence. Confidential location.'),
(@org4,  'YWCA Moncton',                      'shelter_housing',  '135 Kendra St, Moncton, NB E1C 3B9',          'info@ywcamoncton.com',               '506-855-4349', 'https://ywcamoncton.com',           'Supportive housing and programs for women and children ages 16+.'),
(@org5,  'John Howard Society of SE NB',      'shelter_housing',  '15 Flanders Court, Moncton, NB E1C 9H9',      'info@johnhowardsenb.com',            '506-854-3499', 'https://johnhowardsenb.com',        'Transitional housing and reintegration support for justice-involved men.'),
(@org6,  'Peter McKee Community Food Centre', 'food_nutrition',   '66 Capitol St, Moncton, NB E1C 0C5',          'info@petermckeecfc.ca',              '506-383-4281', 'https://petermckeecfc.ca',          'Food bank and community kitchen. Distributes to 200+ households weekly.'),
(@org7,  'Second Mile Food Bank',             'food_nutrition',   '243 Lewisville Rd, Moncton, NB E1A 2Y5',      'info@secondmilefoodbank.ca',         '506-857-9121', 'https://secondmilefoodbank.ca',     'Community food bank serving the Dieppe and east Moncton areas.'),
(@org8,  'Salvation Army Community Services', 'goods_essentials', '32 King St, Moncton, NB E1C 2K1',             'moncton@salvationarmy.ca',           '506-389-9901', 'https://salvationarmy.ca/moncton',  'Emergency services, family support, and essential goods distribution.'),
(@org9,  'St. Vincent de Paul Society',       'goods_essentials', '113 Norwood Ave, Moncton, NB E1C 5S5',        'svdp.moncton@gmail.com',             '506-857-2088', NULL,                                'Clothing depot and household goods. Serves general public in need.'),
(@org10, 'The Humanity Project',              'outreach',         '449 St George St, Moncton, NB E1C 1Y3',       'TheHumanityProjectNB@gmail.com',     '506-382-6840', NULL,                                'Street outreach, meals, and housing navigation support for anyone in need.');

-- ============================================================
-- STAFF MEMBERS  (password = password123 for all)
-- ============================================================
INSERT INTO staff_members (id, org_id, first_name, last_name, email, password_hash, status) VALUES
(@staff1,  @org1,  'Marie',    'Boudreau',   'info@maisonnazareth.ca',             '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff2,  @org2,  'James',    'MacLeod',    'info@harvesthouseatlantic.org',      '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff3,  @org3,  'Linda',    'Cormier',    'adminfo@crossroadsforwomen.ca',      '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff4,  @org4,  'Nicole',   'Theriault',  'info@ywcamoncton.com',              '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff5,  @org5,  'Robert',   'Leger',      'info@johnhowardsenb.com',           '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff6,  @org6,  'Patricia', 'Goguen',     'info@petermckeecfc.ca',             '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff7,  @org7,  'Paul',     'Landry',     'info@secondmilefoodbank.ca',        '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff8,  @org8,  'Susan',    'Doucet',     'moncton@salvationarmy.ca',          '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff9,  @org9,  'Michel',   'Chiasson',   'svdp.moncton@gmail.com',            '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active'),
(@staff10, @org10, 'Angela',   'Roy',        'TheHumanityProjectNB@gmail.com',    '$2a$10$PPjdjpdIUIYRDcI6fCjU0Ov/iodI4WnhjHktaxekQRzcwlSpKgKIm', 'active');

-- ============================================================
-- INVENTORY ITEMS
-- Based on the provided inventory.csv, distributed across orgs.
-- status: available / low / critical / surplus
-- ============================================================

-- ── House of Nazareth ─────────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org1, 'Canned Soup (Chicken Noodle)',   'food',     42,  80,  'cans',   'low',       '2026-09-02', 'Mixed expiry lots'),
(UUID(), @org1, 'Shelf-Stable Milk (1L)',          'food',     22,  50,  'cartons','low',       '2026-04-22', 'Expiring soon — prioritize use'),
(UUID(), @org1, 'Instant Oatmeal Packets',         'food',     18,  40,  'boxes',  'low',       '2026-11-19', NULL),
(UUID(), @org1, 'Bar Soap',                        'hygiene',  60,  50,  'bars',   'surplus',   '2027-03-15', 'Surplus — available for transfer'),
(UUID(), @org1, 'Toothpaste (Standard Tube)',      'hygiene',  35,  60,  'tubes',  'low',       '2027-01-01', NULL),
(UUID(), @org1, 'Travel Toothbrush',               'hygiene',  50,  60,  'units',  'low',       NULL,         NULL),
(UUID(), @org1, 'Hand Sanitizer (Small Bottle)',   'hygiene',  30,  50,  'bottles','low',       '2026-08-18', NULL),
(UUID(), @org1, 'Blankets (Fleece)',               'bedding',  20,  25,  'units',  'available', NULL,         NULL),
(UUID(), @org1, 'Pillow',                          'bedding',  12,  20,  'units',  'low',       NULL,         NULL),
(UUID(), @org1, 'Deodorant Stick',                 'hygiene',  28,  40,  'units',  'low',       '2027-02-02', NULL);

-- ── Harvest House Atlantic ─────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org2, 'Dry Pasta (Spaghetti)',            'food',     65,  50,  'bags',   'surplus',   '2027-04-11', 'Surplus — ready to share'),
(UUID(), @org2, 'Peanut Butter (16 oz Jar)',        'food',     28,  40,  'jars',   'low',       '2026-12-20', NULL),
(UUID(), @org2, 'Granola Bars (Variety Pack)',      'food',     26,  40,  'boxes',  'low',       '2026-08-12', NULL),
(UUID(), @org2, 'Socks (Adult)',                    'clothing', 60,  50,  'pairs',  'surplus',   NULL,         'Surplus — variety of sizes'),
(UUID(), @org2, 'T-Shirt (Men\'s Size L)',           'clothing', 20,  30,  'units',  'low',       NULL,         NULL),
(UUID(), @org2, 'Jeans (Men\'s Size 34)',            'clothing', 10,  15,  'units',  'low',       NULL,         NULL),
(UUID(), @org2, 'Underwear (Men\'s Size M)',         'clothing', 18,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org2, 'Bedsheet Set (Twin)',              'bedding',  14,  20,  'sets',   'low',       NULL,         NULL),
(UUID(), @org2, 'Blankets (Heavy Thermal)',         'bedding',  10,  20,  'units',  'low',       NULL,         NULL),
(UUID(), @org2, 'Sleeping Bags',                   'bedding',   6,  12,  'units',  'low',       NULL,         'Needed for overflow capacity');

-- ── Crossroads for Women ───────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org3, 'Feminine Hygiene Pads (Pack)',    'hygiene',  35,  50,  'packs',  'low',       '2027-04-01', NULL),
(UUID(), @org3, 'Shampoo (Travel Size)',            'hygiene',  40,  50,  'bottles','low',       '2026-10-10', NULL),
(UUID(), @org3, 'Toothpaste (Standard Tube)',       'hygiene',  20,  35,  'tubes',  'low',       '2026-09-09', NULL),
(UUID(), @org3, 'Bar Soap',                         'hygiene',  25,  40,  'bars',   'low',       '2026-12-01', NULL),
(UUID(), @org3, 'Deodorant Stick',                  'hygiene',  12,  25,  'units',  'low',       '2026-11-11', NULL),
(UUID(), @org3, 'Disposable Razors (Pack)',         'hygiene',  20,  30,  'packs',  'low',       NULL,         NULL),
(UUID(), @org3, 'Bedsheet Set (Full)',              'bedding',   8,  15,  'sets',   'low',       NULL,         NULL),
(UUID(), @org3, 'Pillowcase',                       'bedding',  20,  30,  'units',  'low',       NULL,         NULL),
(UUID(), @org3, 'Crackers (Saltine Box)',            'food',     18,  30,  'boxes',  'low',       '2026-08-05', NULL),
(UUID(), @org3, 'Applesauce Cups (Pack)',            'food',     14,  25,  'packs',  'low',       '2026-07-28', NULL);

-- ── YWCA Moncton ───────────────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org4, 'Feminine Hygiene Pads (Pack)',    'hygiene',  10,  40,  'packs',  'critical',  '2026-12-12', 'Urgently needed — stock critically low'),
(UUID(), @org4, 'Shampoo (Travel Size)',            'hygiene',  18,  40,  'bottles','low',       '2027-01-20', NULL),
(UUID(), @org4, 'Travel Toothbrush',               'hygiene',  30,  50,  'units',  'low',       NULL,         NULL),
(UUID(), @org4, 'Granola Bars (Variety Pack)',      'food',     16,  30,  'boxes',  'low',       '2026-08-12', NULL),
(UUID(), @org4, 'Applesauce Cups (Pack)',            'food',      7,  25,  'packs',  'critical',  '2026-10-10', NULL),
(UUID(), @org4, 'Beanie Hats',                     'clothing',  15,  20,  'units',  'low',       NULL,         NULL),
(UUID(), @org4, 'Gloves (Winter)',                  'clothing',  12,  25,  'pairs',  'low',       NULL,         NULL),
(UUID(), @org4, 'Socks (Adult)',                    'clothing',  25,  40,  'pairs',  'low',       NULL,         NULL),
(UUID(), @org4, 'Canned Beans (Black)',             'food',     30,  50,  'cans',   'low',       '2027-01-10', NULL),
(UUID(), @org4, 'Pillowcase',                       'bedding',  20,  30,  'units',  'low',       NULL,         NULL);

-- ── John Howard Society ────────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org5, 'T-Shirt (Men\'s Size XL)',          'clothing', 16,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org5, 'T-Shirt (Men\'s Size L)',           'clothing', 14,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org5, 'Underwear (Men\'s Size L)',         'clothing', 22,  30,  'units',  'low',       NULL,         NULL),
(UUID(), @org5, 'Underwear (Men\'s Size XL)',        'clothing', 15,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org5, 'Jeans (Men\'s Size 32)',            'clothing',  8,  15,  'units',  'low',       NULL,         NULL),
(UUID(), @org5, 'Jeans (Men\'s Size 36)',            'clothing',  7,  15,  'units',  'critical',  NULL,         'Critically low — need restocking'),
(UUID(), @org5, 'Winter Jacket (Men\'s Size L)',     'clothing',  5,  12,  'units',  'critical',  NULL,         'Season not over — critical need'),
(UUID(), @org5, 'Winter Jacket (Men\'s Size XL)',    'clothing',  4,  12,  'units',  'critical',  NULL,         'Season not over — critical need'),
(UUID(), @org5, 'Bar Soap',                         'hygiene',  30,  40,  'bars',   'low',       NULL,         NULL),
(UUID(), @org5, 'Deodorant Stick',                  'hygiene',  20,  35,  'units',  'low',       '2027-02-02', NULL);

-- ── Peter McKee Community Food Centre ─────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org6, 'Canned Soup (Chicken Noodle)',    'food',     24,  80,  'cans',   'critical',  '2026-07-15', 'Primary distribution item — restock urgently'),
(UUID(), @org6, 'Canned Beans (Black)',             'food',     12,  60,  'cans',   'critical',  '2026-11-03', NULL),
(UUID(), @org6, 'Shelf-Stable Milk (1L)',           'food',     14,  50,  'cartons','critical',  '2026-05-30', 'Near expiry — needs immediate distribution'),
(UUID(), @org6, 'Peanut Butter (16 oz Jar)',        'food',      8,  40,  'jars',   'critical',  '2027-02-14', NULL),
(UUID(), @org6, 'White Rice (2 lb Bag)',            'food',     15,  50,  'bags',   'critical',  '2027-05-01', NULL),
(UUID(), @org6, 'Dry Pasta (Spaghetti)',            'food',     25,  60,  'bags',   'low',       '2027-06-30', NULL),
(UUID(), @org6, 'Crackers (Saltine Box)',           'food',      9,  40,  'boxes',  'critical',  '2026-09-14', NULL),
(UUID(), @org6, 'Granola Bars (Variety Pack)',      'food',     10,  40,  'boxes',  'critical',  '2026-10-01', NULL),
(UUID(), @org6, 'Instant Oatmeal Packets',          'food',      6,  30,  'boxes',  'critical',  '2026-09-07', NULL),
(UUID(), @org6, 'Applesauce Cups (Pack)',            'food',      7,  30,  'packs',  'critical',  '2026-10-10', NULL);

-- ── Second Mile Food Bank ──────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org7, 'Canned Soup (Chicken Noodle)',    'food',     18,  50,  'cans',   'low',       '2026-09-02', NULL),
(UUID(), @org7, 'Dry Pasta (Spaghetti)',            'food',     40,  40,  'bags',   'available', '2027-04-11', NULL),
(UUID(), @org7, 'White Rice (2 lb Bag)',            'food',     10,  30,  'bags',   'low',       '2027-03-18', NULL),
(UUID(), @org7, 'Canned Beans (Black)',             'food',     12,  35,  'cans',   'low',       '2026-11-03', NULL),
(UUID(), @org7, 'Instant Oatmeal Packets',          'food',      6,  25,  'boxes',  'critical',  '2026-09-07', NULL),
(UUID(), @org7, 'Crackers (Saltine Box)',           'food',      9,  30,  'boxes',  'critical',  '2026-09-14', NULL),
(UUID(), @org7, 'Toilet Paper Rolls',              'household',100,  80,  'rolls',  'surplus',   NULL,         'Surplus — available to share with network'),
(UUID(), @org7, 'Bar Soap',                        'hygiene',  30,  30,  'bars',   'available', NULL,         NULL),
(UUID(), @org7, 'Peanut Butter (16 oz Jar)',        'food',     20,  30,  'jars',   'low',       '2026-12-20', NULL),
(UUID(), @org7, 'Shelf-Stable Milk (1L)',           'food',     22,  40,  'cartons','low',       '2026-04-22', 'Expiring soon');

-- ── Salvation Army Community Services ─────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org8, 'Socks (Adult)',                   'clothing', 60,  50,  'pairs',  'surplus',   NULL,         'Surplus — various sizes available'),
(UUID(), @org8, 'Beanie Hats',                     'clothing', 15,  20,  'units',  'low',       NULL,         NULL),
(UUID(), @org8, 'Gloves (Winter)',                 'clothing', 12,  20,  'pairs',  'low',       NULL,         NULL),
(UUID(), @org8, 'Blankets (Fleece)',               'bedding',  20,  20,  'units',  'available', NULL,         NULL),
(UUID(), @org8, 'T-Shirt (Men\'s Size M)',          'clothing', 14,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org8, 'Granola Bars (Variety Pack)',     'food',     16,  25,  'boxes',  'low',       '2026-08-12', NULL),
(UUID(), @org8, 'Hand Sanitizer (Small Bottle)',   'hygiene',  15,  30,  'bottles','low',       '2026-11-25', NULL),
(UUID(), @org8, 'Bar Soap',                        'hygiene',  60,  50,  'bars',   'surplus',   NULL,         'Surplus available'),
(UUID(), @org8, 'Toilet Paper Rolls',              'household', 80,  80,  'rolls',  'available', NULL,         NULL),
(UUID(), @org8, 'Deodorant Stick',                 'hygiene',  28,  35,  'units',  'low',       '2027-02-02', NULL);

-- ── St. Vincent de Paul Society ────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org9, 'T-Shirt (Men\'s Size L)',          'clothing', 20,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org9, 'T-Shirt (Men\'s Size XL)',         'clothing', 16,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org9, 'T-Shirt (Men\'s Size M)',          'clothing', 14,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org9, 'Jeans (Men\'s Size 34)',           'clothing', 10,  15,  'units',  'low',       NULL,         NULL),
(UUID(), @org9, 'Jeans (Men\'s Size 32)',           'clothing',  8,  15,  'units',  'low',       NULL,         NULL),
(UUID(), @org9, 'Winter Jacket (Men\'s Size L)',    'clothing',  5,  10,  'units',  'critical',  NULL,         'Running very low for the season'),
(UUID(), @org9, 'Socks (Adult)',                   'clothing', 60,  50,  'pairs',  'surplus',   NULL,         'Surplus available for transfer'),
(UUID(), @org9, 'Underwear (Men\'s Size M)',        'clothing', 18,  25,  'units',  'low',       NULL,         NULL),
(UUID(), @org9, 'Bedsheet Set (Twin)',              'bedding',  14,  20,  'sets',   'low',       NULL,         NULL),
(UUID(), @org9, 'Pillow',                          'bedding',  12,  20,  'units',  'low',       NULL,         NULL);

-- ── The Humanity Project ───────────────────────────────────────
INSERT INTO inventory_items (id, org_id, item_name, category, quantity, target_quantity, unit, status, expiry_date, notes) VALUES
(UUID(), @org10, 'Bar Soap',                       'hygiene',  25,  40,  'bars',   'low',       NULL,         'For outreach hygiene kits'),
(UUID(), @org10, 'Hand Sanitizer (Small Bottle)',  'hygiene',  15,  30,  'bottles','low',       '2026-08-18', NULL),
(UUID(), @org10, 'Travel Toothbrush',              'hygiene',  30,  50,  'units',  'low',       NULL,         NULL),
(UUID(), @org10, 'Deodorant Stick',                'hygiene',  12,  25,  'units',  'low',       '2026-11-11', NULL),
(UUID(), @org10, 'Toothpaste (Standard Tube)',     'hygiene',  20,  40,  'tubes',  'low',       '2026-09-09', NULL),
(UUID(), @org10, 'Granola Bars (Variety Pack)',    'food',     10,  25,  'boxes',  'low',       '2026-08-12', 'For street outreach kits'),
(UUID(), @org10, 'Canned Soup (Chicken Noodle)',   'food',     18,  30,  'cans',   'low',       '2026-07-15', NULL),
(UUID(), @org10, 'Applesauce Cups (Pack)',          'food',      7,  20,  'packs',  'critical',  '2026-07-28', NULL),
(UUID(), @org10, 'Socks (Adult)',                  'clothing', 40,  50,  'pairs',  'low',       NULL,         'High turnover — outreach distribution'),
(UUID(), @org10, 'Sleeping Bags',                  'bedding',   6,  10,  'units',  'low',       NULL,         'For unsheltered individuals');

-- ============================================================
-- NEEDS  (mix of active and fulfilled for analytics)
-- ============================================================

-- Fulfilled needs — spread over past 30 days (for analytics "needs_fulfilled" chart)
INSERT INTO needs (id, org_id, item_name, category, quantity_needed, unit, urgency, notes, fulfilled, fulfilled_at) VALUES
(UUID(), @org1,  'Winter Jackets (Various Sizes)',     'clothing', 20, 'units', 'high',     'Residents arriving from the cold — needed urgently',          1, '2026-02-14 10:00:00'),
(UUID(), @org6,  'Canned Vegetables (Assorted)',       'food',    150, 'cans',  'critical', 'Weekly distribution to 200+ households — stock depleted',     1, '2026-02-18 09:00:00'),
(UUID(), @org3,  'Feminine Hygiene Products (Pack)',   'hygiene',  60, 'packs', 'critical', 'Essential supply for residents — fully depleted',             1, '2026-02-20 11:00:00'),
(UUID(), @org10, 'Hygiene Kits (Travel-size bundle)',  'hygiene',  50, 'kits',  'high',     'For street outreach — distributed immediately upon receipt',  1, '2026-02-22 14:00:00'),
(UUID(), @org2,  'Sleeping Bags (Cold-Weather)',       'bedding',  15, 'units', 'critical', 'Winter overflow — resolved with community donation drive',     1, '2026-02-25 08:30:00'),
(UUID(), @org7,  'Non-Perishable Food Boxes',          'food',     80, 'boxes', 'high',     'March distribution — covered by food drive',                  1, '2026-02-28 10:00:00'),
(UUID(), @org5,  'Men\'s Work Boots (Various Sizes)',  'clothing', 12, 'pairs', 'medium',   'For residents in employment programs',                         1, '2026-03-02 15:00:00'),
(UUID(), @org4,  'Children\'s Clothing (Ages 3–10)',   'clothing', 30, 'units', 'high',     'Family intake increase — donation matched by SVDP',           1, '2026-03-04 09:00:00'),
(UUID(), @org8,  'Household Cleaning Supplies',        'household',40, 'units', 'medium',   'Monthly restocking — fulfilled via supplier donation',        1, '2026-03-06 11:00:00'),
(UUID(), @org9,  'Bedsheet Sets (Various Sizes)',      'bedding',  25, 'sets',  'medium',   'Needed for increased bed count',                              1, '2026-03-08 13:00:00'),
(UUID(), @org1,  'Toilet Paper (Bulk)',                'household',200,'rolls', 'high',     'Critical household supply — fulfilled via Second Mile transfer', 1, '2026-03-10 10:00:00'),
(UUID(), @org6,  'Baby Formula (Various Ages)',        'food',     30, 'units', 'critical', 'For families with infants — sourced through Salvation Army', 1, '2026-03-12 09:00:00');

-- Active needs — current unfulfilled needs across the network
INSERT INTO needs (id, org_id, item_name, category, quantity_needed, unit, urgency, notes, fulfilled, fulfilled_at) VALUES
-- Critical
(UUID(), @org6,  'Canned Soup (Chicken Noodle)',       'food',    100, 'cans',   'critical', 'Primary food bank item — stock dangerously low',              0, NULL),
(UUID(), @org6,  'Peanut Butter (16 oz Jar)',          'food',     60, 'jars',   'critical', 'High-protein staple — nearly depleted',                       0, NULL),
(UUID(), @org4,  'Feminine Hygiene Pads',              'hygiene',  50, 'packs',  'critical', 'Running out — clients in urgent need',                        0, NULL),
(UUID(), @org5,  'Winter Jacket (Men\'s Size L/XL)',   'clothing', 20, 'units',  'critical', 'Men leaving justice system need winter gear immediately',     0, NULL),
(UUID(), @org7,  'Instant Oatmeal / Breakfast Items',  'food',     40, 'boxes',  'critical', 'No breakfast stock left in distribution room',                0, NULL),
(UUID(), @org10, 'Sleeping Bags (Outdoor Grade)',      'bedding',  10, 'units',  'critical', 'Unsheltered individuals — temperatures still below zero',     0, NULL),
-- High
(UUID(), @org1,  'Shelf-Stable Milk (1L)',             'food',     60, 'cartons','high',     'For families with children — supply very low',                0, NULL),
(UUID(), @org2,  'Blankets (Heavy Thermal)',           'bedding',  20, 'units',  'high',     'Incoming residents from encampments need bedding',            0, NULL),
(UUID(), @org3,  'Shampoo & Conditioner',              'hygiene',  40, 'bottles','high',     'Basic hygiene supply for new residents',                      0, NULL),
(UUID(), @org8,  'Children\'s Winter Boots (Various)', 'clothing', 15, 'pairs',  'high',     'Families with young children — winter still ongoing',         0, NULL),
(UUID(), @org9,  'Men\'s Jeans (Size 32–38)',          'clothing', 25, 'units',  'high',     'Most requested item — stock very low',                        0, NULL),
(UUID(), @org6,  'White Rice (2 lb Bags)',             'food',     60, 'bags',   'high',     'Staple food item — distribution day tomorrow',                0, NULL),
-- Medium
(UUID(), @org1,  'Travel Toothbrush & Toothpaste Kit', 'hygiene',  50, 'kits',  'medium',   'For new arrivals hygiene packs',                              0, NULL),
(UUID(), @org2,  'Socks (Adult, Thick)',               'clothing', 40, 'pairs',  'medium',   'High turnover item — continuous need',                        0, NULL),
(UUID(), @org4,  'Children\'s Books & Activities',    'other',    20, 'units',  'medium',   'Family lounge activities for children in residence',          0, NULL),
(UUID(), @org7,  'Crackers & Shelf-Stable Snacks',     'food',     50, 'boxes',  'medium',   'For hamper packing — weekly need',                           0, NULL),
(UUID(), @org10, 'Granola Bars / Snack Bars',         'food',     80, 'boxes',  'medium',   'Distributed during street outreach',                          0, NULL),
(UUID(), @org5,  'Underwear (Men\'s Size M–XL)',       'clothing', 30, 'units',  'medium',   'Requested weekly by new program participants',                0, NULL),
-- Low
(UUID(), @org3,  'Board Games & Activity Kits',       'other',    10, 'units',  'low',      'For communal area — therapeutic recreation',                  0, NULL),
(UUID(), @org8,  'Reusable Shopping Bags',            'household', 50, 'units', 'low',      'For hamper distribution',                                     0, NULL),
(UUID(), @org9,  'Hangers (Bulk)',                    'household',100, 'units', 'low',      'For clothing depot display and sorting',                      0, NULL);

-- ============================================================
-- DONATIONS  (spread over past 30 days, all pipeline stages)
-- Delivered donations have spread dates for analytics chart
-- ============================================================

-- Delivered donations (7–30 days ago — shows healthy pipeline activity)
INSERT INTO donations (id, donor_name, donor_email, donor_phone, item_name, category, quantity, unit, `condition`, preferred_org_id, matched_org_id, status, ai_match_reasoning, pickup_notes, created_at, updated_at) VALUES
(UUID(), 'Margaret Arsenault', 'margaret.arsenault@gmail.com',   '506-555-0101', 'Canned Soup (Chicken Noodle)', 'food',    48, 'cans',    'new',  @org6,  @org6,  'delivered', 'Matched to Peter McKee Food Centre based on critical stock levels and weekly distribution schedule. This donation directly addresses their highest-priority food item shortage.', 'Dropped off at Capitol St location, 9am', DATE_SUB(NOW(), INTERVAL 28 DAY), DATE_SUB(NOW(), INTERVAL 26 DAY)),
(UUID(), 'Pierre Goguen',       'pierre.goguen@hotmail.com',       '506-555-0102', 'Winter Jackets (Men\'s Assorted)', 'clothing', 12, 'units',   'good', NULL,   @org5,  'delivered', 'Cross-referenced urgent needs with stock levels. John Howard Society has critical shortage of winter jackets for justice-involved men re-entering the community. High-impact match.', 'Picked up by coordinator — 12 jackets sorted by size', DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 23 DAY)),
(UUID(), 'Sarah Leblanc',       'sarah.leblanc@nb.ca',             '506-555-0103', 'Feminine Hygiene Pads (Pack)',  'hygiene', 36, 'packs',   'new',  @org3,  @org3,  'delivered', 'Matched to Crossroads for Women — shelter for domestic violence survivors. Stock is critically low and this is a non-negotiable essential for residents.', NULL, DATE_SUB(NOW(), INTERVAL 22 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)),
(UUID(), 'Tim Hortons Moncton', 'community@timhortons.com',        '506-555-0104', 'Granola Bars (Variety Pack)',   'food',    120,'boxes',   'new',  NULL,   @org6,  'delivered', 'Corporate donation matched to network\'s highest-need food bank. Distributed across Peter McKee and Harvest House based on stock shortfall analysis.', 'Pallet delivery to Capitol St — 120 boxes sorted', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 18 DAY)),
(UUID(), 'Jean-Marc Léger',     'jmlegerfamily@gmail.com',         '506-555-0105', 'Sleeping Bags (Camping Grade)', 'bedding',  8, 'units',   'good', @org10, @org10, 'delivered', 'Matched to The Humanity Project — street outreach program. Donation is urgently needed for unsheltered individuals. Excellent condition and appropriate for outdoor use.', 'Delivered to St George St location', DATE_SUB(NOW(), INTERVAL 18 DAY), DATE_SUB(NOW(), INTERVAL 16 DAY)),
(UUID(), 'Molson-Coors NB',     'giving@molsoncoors.com',          '506-555-0106', 'Blankets (Fleece)',             'bedding', 50, 'units',   'new',  NULL,   @org2,  'delivered', 'Harvest House Atlantic has incoming capacity from encampment relocation. New thermal blankets matched to highest occupancy shelter with most acute bedding shortage.', 'Truck delivery — blankets distributed same day', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
(UUID(), 'Anne-Marie Breau',    'ambreau@acadienet.ca',             '506-555-0107', 'Toothpaste & Toothbrush Sets', 'hygiene', 60, 'kits',    'new',  @org1,  @org1,  'delivered', 'House of Nazareth requested hygiene intake kits for new arrivals. This donation perfectly matches their posted need — 60 kits for expected monthly intake.', NULL, DATE_SUB(NOW(), INTERVAL 13 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY)),
(UUID(), 'Reza Moradi',         'reza.moradi@unb.ca',               '506-555-0108', 'Peanut Butter (16 oz Jar)',    'food',    30, 'jars',    'new',  @org6,  @org6,  'delivered', 'Matched Peter McKee food bank critical peanut butter shortage. High-calorie staple for food insecure households. Donor can deliver to Capitol St directly.', 'Donor delivered directly', DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
(UUID(), 'First Baptist Moncton','giving@firstbaptistmoncton.ca',   '506-555-0109', 'Dry Pasta (Spaghetti)',         'food',    60, 'bags',    'new',  NULL,   @org7,  'delivered', 'Second Mile Food Bank currently meeting targets but upcoming distribution drive will deplete stock. Proactive match supports Dieppe community program continuity.', 'Church volunteers delivered 4 boxes', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(UUID(), 'Carolyne Chiasson',   'carolyne.c@rogers.com',            '506-555-0110', 'Children\'s Clothing (Mixed)',  'clothing',25, 'units',   'good', @org4,  @org4,  'delivered', 'YWCA Moncton currently housing 6 families with children ages 3–12. Posted need matches exact size range offered. Fulfills active critical need.', NULL, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
(UUID(), 'Louis Melanson',      'lmelanson@nb.aibn.com',            '506-555-0111', 'White Rice (2 lb Bags)',        'food',    40, 'bags',    'new',  @org6,  @org6,  'delivered', 'Peter McKee Food Centre has a critical gap in staple starch items. White rice directly addresses their posted high-urgency need and incoming distribution day.', 'Left at loading dock with coordinator', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(UUID(), 'TD Bank Moncton',     'community@td.com',                 '506-555-0112', 'Socks (Adult Variety)',         'clothing',80, 'pairs',   'new',  NULL,   @org8,  'delivered', 'Corporate donation matched to Salvation Army for broad network distribution. Socks are among the most requested items network-wide. Enough to supply 4 organizations.', 'Delivered to King St — split with SVDP arranged', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Confirmed donations (ready for delivery)
INSERT INTO donations (id, donor_name, donor_email, donor_phone, item_name, category, quantity, unit, `condition`, preferred_org_id, matched_org_id, status, ai_match_reasoning, pickup_notes, created_at, updated_at) VALUES
(UUID(), 'Acadian Gas Station Group', 'acadian.gives@gmail.com',   '506-555-0113', 'Granola Bars (Case)',            'food',    48, 'boxes',   'new',  NULL,   @org10, 'confirmed', 'The Humanity Project street outreach team requested snack bars for daily distribution kits. This donation quantity covers approximately 3 weeks of outreach.', 'Pickup scheduled for Monday morning', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(UUID(), 'Rotary Club of Moncton',   'president@rotarymoncton.ca', '506-555-0114', 'Bedsheet Sets (Twin)',           'bedding', 20, 'sets',    'new',  NULL,   @org2,  'confirmed', 'Harvest House Atlantic transitional housing unit needs full bedding refresh for new resident cohort. 20 twin sets exactly matches their posted medium need.', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(UUID(), 'Université de Moncton',    'dons@umoncton.ca',           '506-555-0115', 'Feminine Hygiene Pads (Pack)',   'hygiene', 40, 'packs',   'new',  @org4,  @org4,  'confirmed', 'YWCA Moncton is at critically low inventory for feminine hygiene. University student drive donated exactly what was needed — matched to highest-urgency recipient.', 'Campus coordinator will drop off this week', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(UUID(), 'Home Depot Moncton',       'community@homedepot.ca',     '506-555-0116', 'Sleeping Bags (Expedition)',     'bedding',  8, 'units',   'new',  @org10, @org10, 'confirmed', 'The Humanity Project outreach team has a posted critical need for outdoor-grade sleeping bags for unsheltered individuals. Corporate donation of expedition-grade bags is an excellent match.', 'Store will hold for coordinator pickup', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

-- Matched donations (AI-matched, awaiting coordinator confirmation)
INSERT INTO donations (id, donor_name, donor_email, donor_phone, item_name, category, quantity, unit, `condition`, preferred_org_id, matched_org_id, status, ai_match_reasoning, pickup_notes, created_at, updated_at) VALUES
(UUID(), 'Gabriel Robichaud', 'gabriel.rob@live.ca',         '506-555-0117', 'Winter Jacket (Men\'s Size XL)', 'clothing', 5, 'units',   'good', NULL,   @org5,  'matched', 'AI matched to John Howard Society — they have a critical shortage of men\'s XL winter jackets for program participants. Exact size and season match. Recommend immediate confirmation.', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(UUID(), 'Isabelle Cyr',      'isacyr@gmail.com',            '506-555-0118', 'Canned Beans & Lentils (Mixed)',  'food',    36, 'cans',    'new',  NULL,   @org6,  'matched', 'Matched to Peter McKee Food Centre based on critical canned food deficit. Network analysis shows this organization has the highest food item need per capita served. Confirm to complete match.', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(UUID(), 'Kijiji Seller',     'donate@kijiji.ca',            NULL,           'Bedsheet Set (Full) & Pillowcases','bedding',10, 'sets',    'fair', NULL,   @org3,  'matched', 'Crossroads for Women residential unit has low bedding stock for full-size beds. Fair-condition linens are acceptable per shelter standards. Quantity fills approximately half the posted need.', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(UUID(), 'Sylvie Bourgeois',  'sylvie.bg@rogers.com',        '506-555-0119', 'Toothpaste & Toothbrush Sets',   'hygiene', 30, 'kits',    'new',  NULL,   @org10, 'matched', 'The Humanity Project distributes hygiene kits during street outreach. This donation fills the medium-urgency posted need. Matches quantity, condition, and item type exactly.', NULL, NOW(), NOW()),
(UUID(), 'Canadian Tire NB',  'community@canadiantire.ca',   '506-555-0120', 'Socks (Adult Thick, Winter)',     'clothing',60, 'pairs',   'new',  NULL,   @org1,  'matched', 'House of Nazareth has an ongoing high-volume need for adult socks. Corporate donation of 60 pairs matches their weekly intake needs. Cold weather still ongoing — time-sensitive.', NULL, NOW(), NOW());

-- Pending donations (just submitted — awaiting AI matching)
INSERT INTO donations (id, donor_name, donor_email, donor_phone, item_name, category, quantity, unit, `condition`, preferred_org_id, matched_org_id, status, ai_match_reasoning, pickup_notes, created_at, updated_at) VALUES
(UUID(), 'Darren McKenzie',    'darren.mckenzie@nb.ca',       '506-555-0121', 'Blankets (Fleece)',              'bedding', 10, 'units',   'good', NULL,   NULL,   'pending', NULL, NULL, NOW(), NOW()),
(UUID(), 'Rachel Colpitts',    'rachel.colpitts@hotmail.com', '506-555-0122', 'Canned Soup (Tomato)',           'food',    24, 'cans',    'new',  @org7,  NULL,   'pending', NULL, NULL, NOW(), NOW()),
(UUID(), 'Church of Moncton',  'admin@churchofmoncton.com',   '506-555-0123', 'Men\'s Clothing (Mixed Lot)',    'clothing',30, 'units',   'good', NULL,   NULL,   'pending', NULL, NULL, NOW(), NOW()),
(UUID(), 'Stéphanie Martin',   'stephanie.martin@ub.ca',      '506-555-0124', 'Granola Bars & Snacks',          'food',    20, 'boxes',   'new',  @org10, NULL,   'pending', NULL, NULL, NOW(), NOW()),
(UUID(), 'Walmart Moncton',    'community@walmart.ca',        '506-555-0125', 'Toiletry Starter Kits',          'hygiene', 50, 'kits',    'new',  NULL,   NULL,   'pending', NULL, NULL, NOW(), NOW());

-- ============================================================
-- SURPLUS TRANSFERS (completed and active)
-- ============================================================

-- Completed transfers — show in analytics "transfers_completed"
INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org7, @org1, i.id, 50, 'completed', 'Surplus toilet paper from Second Mile transferred to House of Nazareth — immediate need confirmed by staff.', DATE_SUB(NOW(), INTERVAL 21 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM inventory_items i WHERE i.org_id = @org7 AND i.item_name = 'Toilet Paper Rolls' LIMIT 1;

INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org2, @org5, i.id, 25, 'completed', 'Surplus socks from Harvest House shared with John Howard Society — men\'s program requested immediately.', DATE_SUB(NOW(), INTERVAL 17 DAY), DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM inventory_items i WHERE i.org_id = @org2 AND i.item_name = 'Socks (Adult)' LIMIT 1;

INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org1, @org6, i.id, 20, 'completed', 'Bar soap surplus from House of Nazareth transferred to Peter McKee — they were completely out for hygiene distribution.', DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM inventory_items i WHERE i.org_id = @org1 AND i.item_name = 'Bar Soap' LIMIT 1;

INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org2, @org10, i.id, 15, 'completed', 'Dry pasta surplus redirected to Humanity Project outreach meal program — reduces food waste and meets urgent need.', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM inventory_items i WHERE i.org_id = @org2 AND i.item_name = 'Dry Pasta (Spaghetti)' LIMIT 1;

INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org8, @org3, i.id, 20, 'completed', 'Socks surplus from Salvation Army redistributed to Crossroads for Women — new resident cohort arriving this week.', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM inventory_items i WHERE i.org_id = @org8 AND i.item_name = 'Socks (Adult)' LIMIT 1;

INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org9, @org5, i.id, 5, 'completed', 'SVDP transferred critical winter jackets to John Howard Society — season end approaching and men re-entering need outerwear.', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM inventory_items i WHERE i.org_id = @org9 AND i.item_name = 'Winter Jacket (Men\'s Size L)' LIMIT 1;

-- In-transit transfers
INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org7, @org6, i.id, 30, 'in_transit', 'Toilet paper from Second Mile to Peter McKee — household supply critically low at food centre. Pickup arranged for today.', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL
FROM inventory_items i WHERE i.org_id = @org7 AND i.item_name = 'Toilet Paper Rolls' LIMIT 1;

INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org8, @org4, i.id, 10, 'in_transit', 'Bar soap from Salvation Army surplus going to YWCA — requested for incoming residents this week.', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL
FROM inventory_items i WHERE i.org_id = @org8 AND i.item_name = 'Bar Soap' LIMIT 1;

-- Pending transfer (awaiting approval)
INSERT INTO surplus_transfers (id, from_org_id, to_org_id, inventory_item_id, quantity, status, coordinator_notes, created_at, completed_at)
SELECT UUID(), @org9, @org10, i.id, 30, 'pending', 'SVDP socks surplus — proposed transfer to Humanity Project for outreach kits. Awaiting pickup logistics confirmation.', NOW(), NULL
FROM inventory_items i WHERE i.org_id = @org9 AND i.item_name = 'Socks (Adult)' LIMIT 1;

-- ============================================================
-- Summary confirmation
-- ============================================================
SELECT 'SEED COMPLETE' AS status;
SELECT 'Organizations' AS `table`, COUNT(*) AS count FROM organizations
UNION ALL SELECT 'Staff Members', COUNT(*) FROM staff_members
UNION ALL SELECT 'Admins', COUNT(*) FROM admins
UNION ALL SELECT 'Inventory Items', COUNT(*) FROM inventory_items
UNION ALL SELECT 'Needs (total)', COUNT(*) FROM needs
UNION ALL SELECT 'Needs (active)', COUNT(*) FROM needs WHERE fulfilled = 0
UNION ALL SELECT 'Needs (fulfilled)', COUNT(*) FROM needs WHERE fulfilled = 1
UNION ALL SELECT 'Donations (total)', COUNT(*) FROM donations
UNION ALL SELECT 'Donations (delivered)', COUNT(*) FROM donations WHERE status = 'delivered'
UNION ALL SELECT 'Surplus Transfers', COUNT(*) FROM surplus_transfers
UNION ALL SELECT 'Completed Transfers', COUNT(*) FROM surplus_transfers WHERE status = 'completed';
