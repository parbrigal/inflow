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
-- sourced from needs.xlsx (Sheet1), with normalized casing
insert into requests (category_id, name, description, status, requested_by) values
((select id from categories where name = 'Living Room'), 'Couch', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Chair', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Coffee Table', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'TV', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Side Table', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Throw Rug', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Floor Lamp', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Shelf/Bookcase/Storage', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'TV Wall Mount', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'TV Stand/Table to Place TV On', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Wall Mounted Shelves', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Living Room'), 'Portable Fan', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Trash Can', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Bath Towels', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Hand Towels', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Face Cloths ', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Shower Curtain', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Shower Liner', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bathroom'), 'Curtain Rings', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Queen Size Sheets', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Pillow Cases', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Queen Size Mattress Cover', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Queen Size Duvet', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Standard Size Pillow', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Side Table', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Lamps', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Dresser Drawer/Something to Store Items You Cannot Hang Up (Example: Socks)', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Adults'), 'Hangers', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Twin/Single Bed Sheet With One Pillow Case', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Twin/Single Mattress Cover', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Twin/Single Duvet', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Standard Pillow', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Hangers', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Dresser Drawer/Something to Store Items You Cannot Hang Up (Example: Socks)', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Toy Storage Ideas', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Side Table', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Child'), 'Lamp For Child''s Room', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Double/Full Bed Sheets With Two Pillow Cases', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Double/Full Bed Mattress Cover', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Drawers With A Mirror', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Hangers', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Double/Full Duvet', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Standard Size Pillows', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Side Table', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Bedside Lamp', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Bedroom - Young Adult'), 'Shelf/Bookcase/Storage', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Toaster/Toaster Oven', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Coffee Maker', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Can Opener', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Large Covered Pot', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Medium Covered Pot', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Small Covered Pot', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Medium Fry Pan', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Large Fry Pan', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Small Mixing Bowl', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Medium Mixing Bowl', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Large Mixing Bowl', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Large Casserole Dish', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Medium Casserole Dish', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14'),
((select id from categories where name = 'Kitchen'), 'Kettle', null, 'pending', '789a8e85-39b2-4fcd-8a75-ad78b6547a14');

-- You can run this with psql or via Supabase SQL editor:
-- \i mock-donations.sql

-- Feel free to change names, counts or add more categories for your tests.
