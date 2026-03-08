-- Mock insert script for donations (and a few items) to seed test data
-- run against your Supabase/Postgres instance after creating the schema

-- (adjust user UUIDs to match accounts in your auth.users table)
-- you can generate new ones with gen_random_uuid() or uuid_generate_v4();

-- example donor IDs (create corresponding profiles if needed)
-- replace these with real UUIDs from auth.users

-- donations
insert into donations (name, description, donor_name, donor_lastname, address, contact_no, status, created_by) values
('Summer Clothes Drive', 'Collecting gently used clothing for families', 'Maria', 'Santos', '123 Rizal St, Manila', '09171234567', 'active', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
('Winter Shelter Supplies', 'Blankets, sleeping bags, and warm gear', 'John', 'Reyes', '45 Mabini Ave, Quezon City', '09981234567', 'active', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
('Food Bank Donation', 'Non-perishable food items and canned goods', 'Liza', 'Cruz', '88 Bonifacio Rd, Pasig', '09192345678', 'completed', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
('Office Cleaning Supplies', 'Disinfectants, paper towels, hand soap', 'Paolo', 'Garcia', '210 Kalayaan St, Makati', '09081234567', 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14');

-- items tied to the first donation
insert into items (donation_id, name, description, quantity, status, created_by) values
(1, 'Men''s Jackets', 'Various sizes', 25, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(1, 'Women''s Jeans', 'Good condition', 40, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14');

-- items for second donation
insert into items (donation_id, name, description, quantity, status, created_by) values
(2, 'Wool Blankets', 'Warm and thick', 60, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(2, 'Sleeping Bags', 'One-person', 30, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14');

-- items for food bank donation
insert into items (donation_id, name, description, quantity, status, created_by) values
(3, 'Canned Soup', 'Chicken noodle', 120, 'distributed', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(3, 'Rice Bags', '5kg each', 50, 'distributed', '789a8e85-39b2-4fcd-8a75-ad78b6547a14');

-- wishlist/requests mock data
-- assumes categories from schema.sql already exist (ids 1..14)
insert into requests (category_id, name, description, status, requested_by) values
(1, 'Kids School Uniforms', 'Sizes 8-14 needed for back-to-school support', 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(2, 'Pillows', 'Standard size pillows for family shelters', 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(3, 'Canned Tuna', 'Easy-open cans preferred', 'reserved', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(4, 'Toothbrush Kits', 'Toothbrush + toothpaste combo packs', 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
(8, 'Cookware Set', 'Basic pots and pans for relocation homes', 'fulfilled', '789a8e85-39b2-4fcd-8a75-ad78b6547a14');

-- You can run this with psql or via Supabase SQL editor:
-- \i mock-donations.sql

-- Feel free to change names, counts or add more categories for your tests.
