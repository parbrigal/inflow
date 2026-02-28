-- Schema for InFlow application
-- Run this in a PostgreSQL/Supabase instance

-- ------------------------------------------------------------------
-- Profiles (extended user information)
-- ------------------------------------------------------------------
create table if not exists profiles (
    id              uuid primary key references auth.users (id) on delete cascade,
    full_name       text,
    avatar_url      text,
    locale          text,
    updated_at      timestamp with time zone default now()
);

-- ------------------------------------------------------------------
-- Donations (top-level container)
-- ------------------------------------------------------------------
create table if not exists donations (
    id              serial        primary key,
    name            text          not null,
    description     text,
    status          text          default 'active',
    created_by      uuid          not null references auth.users (id),
    created_at      timestamp with time zone default now(),
    updated_at      timestamp with time zone default now()
);

-- optionally add an index on created_by if you query by user
create index if not exists donations_created_by_idx on donations(created_by);

-- ------------------------------------------------------------------
-- Categories (item categories)
-- ------------------------------------------------------------------
create table if not exists categories (
    id              serial        primary key,
    name            text          not null unique,
    description     text,
    created_at      timestamp with time zone default now()
);

-- Insert default categories
insert into categories (name, description) values
    ('Clothing & Accessories', 'Clothing, shoes, and accessories'),
    ('Bedding & Linens', 'Bedding, sheets, towels, and linens'),
    ('Food & Pantry Items', 'Food and pantry staples'),
    ('Personal Care & Hygiene', 'Personal care and hygiene products'),
    ('Baby & Kids Items', 'Baby and children items'),
    ('Books & Educational Materials', 'Books and educational resources'),
    ('Furniture', 'Furniture and home furnishings'),
    ('Household Items', 'Household items and kitchenware'),
    ('Electronics', 'Electronic devices and accessories'),
    ('Tools & Equipment', 'Tools and equipment'),
    ('Recreation & Sports', 'Recreation and sports items'),
    ('Medical & Mobility', 'Medical supplies and mobility aids'),
    ('Pet Supplies', 'Pet supplies and accessories'),
    ('Financial & Gift Donations', 'Financial and gift donations')
on conflict (name) do nothing;

-- ------------------------------------------------------------------
-- Items (belong to a donation)
-- ------------------------------------------------------------------
create table if not exists items (
    id              serial        primary key,
    donation_id     integer       not null references donations (id) on delete cascade,
    category_id     integer       references categories (id) on delete set null,
    name            text          not null,
    description     text,
    quantity        integer       default 1,
    status          text          default 'pending',
    created_by      uuid          not null references auth.users (id),
    created_at      timestamp with time zone default now(),
    updated_at      timestamp with time zone default now()
);

create index if not exists items_donation_idx on items(donation_id);
create index if not exists items_category_idx on items(category_id);

-- ------------------------------------------------------------------
-- Attachments (files linked to items)
-- ------------------------------------------------------------------
create table if not exists attachments (
    id              serial        primary key,
    item_id         integer       not null references items (id) on delete cascade,
    file_name       text          not null,
    file_url        text          not null,
    mime_type       text,
    size_bytes      bigint,
    uploaded_by     uuid          references auth.users (id),
    uploaded_at     timestamp with time zone default now()
);

create index if not exists attachments_item_idx on attachments(item_id);

-- ------------------------------------------------------------------
-- Activity (audit trail)
-- ------------------------------------------------------------------
create table if not exists activity (
    id              serial        primary key,
    occurred_at     timestamp with time zone default now(),
    actor_id        uuid          references auth.users (id),
    table_name      text          not null,
    record_id       text          not null,     -- store PK value as text
    action          text          not null,     -- e.g. INSERT, UPDATE, DELETE
    changes         jsonb,                         -- optional diff or payload
    note            text
);

create index if not exists activity_actor_idx on activity(actor_id);
create index if not exists activity_table_idx on activity(table_name);

-- ------------------------------------------------------------------
-- Trigger helpers for automatic auditing (example)
-- ------------------------------------------------------------------
-- you can create functions/triggers that insert into activity
-- whenever certain tables change; omitted here but easy to add
-- ------------------------------------------------------------------
