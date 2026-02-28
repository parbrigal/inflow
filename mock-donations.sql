-- Mock insert script for donations (and a few items) to seed test data
-- run against your Supabase/Postgres instance after creating the schema

-- (adjust user UUIDs to match accounts in your auth.users table)
-- you can generate new ones with gen_random_uuid() or uuid_generate_v4();

-- example donor IDs (create corresponding profiles if needed)
-- replace these with real UUIDs from auth.users

-- donations
insert into donations (name, description, status, created_by) values
('Summer Clothes Drive', 'Collecting gently used clothing for families', 'active', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e'),
('Winter Shelter Supplies', 'Blankets, sleeping bags, and warm gear', 'active', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e'),
('Food Bank Donation', 'Non-perishable food items and canned goods', 'completed', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e'),
('Office Cleaning Supplies', 'Disinfectants, paper towels, hand soap', 'pending', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e');

-- items tied to the first donation
insert into items (donation_id, name, description, quantity, status, created_by) values
(1, 'Men''s Jackets', 'Various sizes', 25, 'pending', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e'),
(1, 'Women''s Jeans', 'Good condition', 40, 'pending', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e');

-- items for second donation
insert into items (donation_id, name, description, quantity, status, created_by) values
(2, 'Wool Blankets', 'Warm and thick', 60, 'pending', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e'),
(2, 'Sleeping Bags', 'One-person', 30, 'pending', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e');

-- items for food bank donation
insert into items (donation_id, name, description, quantity, status, created_by) values
(3, 'Canned Soup', 'Chicken noodle', 120, 'distributed', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e'),
(3, 'Rice Bags', '5kg each', 50, 'distributed', '6093942c-6f40-4f4a-b5fb-12d42fa8e70e');

-- You can run this with psql or via Supabase SQL editor:
-- \i mock-donations.sql

-- Feel free to change names, counts or add more categories for your tests.
