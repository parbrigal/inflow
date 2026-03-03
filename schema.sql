-- Schema for InFlow application
-- Run this in a PostgreSQL/Supabase instance

-- ------------------------------------------------------------------
-- Roles (user roles)
-- ------------------------------------------------------------------
create table if not exists roles (
    id              serial        primary key,
    name            text          not null unique,
    description     text,
    created_at      timestamp with time zone default now()
);

-- Reset the ID sequence
ALTER SEQUENCE roles_id_seq RESTART WITH 1;

-- Insert default roles
insert into roles (name, description) values
    ('Administrator', 'Full system access and administrative privileges'),
    ('Volunteer', 'Can manage donations and items'),
    ('User', 'Basic user access')
on conflict (name) do nothing;

-- ------------------------------------------------------------------
-- Profiles (extended user information)
-- ------------------------------------------------------------------
create table if not exists profiles (
    id              uuid primary key references auth.users (id) on delete cascade,
    full_name       text,
    avatar_url      text,
    locale          text,
    role_id         integer references roles (id) on delete set null default 3,
    updated_at      timestamp with time zone default now()
);

create index if not exists profiles_role_idx on profiles(role_id);

-- ------------------------------------------------------------------
-- Function to create profile on user signup
-- ------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url, role_id)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=' || new.id,
    1
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Create trigger on auth user creation
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ------------------------------------------------------------------
-- Donations (top-level container)
-- ------------------------------------------------------------------
create table if not exists donations (
    id              serial        primary key,
    name            text          not null,
    description     text,
    donor_type      text          not null default 'Individual',
    organization_name text,
    donor_name      text          not null,
    donor_lastname  text          not null,
    address         text          not null,
    contact_no      text          not null,
    status          text          default 'active',
    created_by      uuid          not null references auth.users (id),
    created_at      timestamp with time zone default now(),
    updated_at      timestamp with time zone default now()
);

alter table donations add column if not exists donor_name text not null default '';
alter table donations add column if not exists donor_lastname text not null default '';
alter table donations add column if not exists address text not null default '';
alter table donations add column if not exists contact_no text not null default '';
alter table donations add column if not exists donor_type text not null default 'Individual';
alter table donations add column if not exists organization_name text;

-- Reset the ID sequence
ALTER SEQUENCE donations_id_seq RESTART WITH 1;

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

-- Reset the ID sequence
ALTER SEQUENCE categories_id_seq RESTART WITH 1;

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
-- Items (can optionally belong to a donation)
-- ------------------------------------------------------------------
create table if not exists items (
    id              serial        primary key,
    donation_id     integer       references donations (id) on delete set null,
    category_id     integer       references categories (id) on delete set null,
    name            text          not null,
    description     text,
    quantity        integer       default 1,
    status          text          default 'pending',
    created_by      uuid          not null references auth.users (id),
    created_at      timestamp with time zone default now(),
    updated_at      timestamp with time zone default now()
);

-- Reset the ID sequence
ALTER SEQUENCE items_id_seq RESTART WITH 1;

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
