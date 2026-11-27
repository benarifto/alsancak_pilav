-- ============================================================
-- Migration 002: Row Level Security (RLS)
-- Run AFTER 001_schema.sql
-- ============================================================

-- ============================================================
-- Enable RLS on all tables
-- ============================================================
alter table public.restaurants enable row level security;
alter table public.categories  enable row level security;
alter table public.products    enable row level security;

-- ============================================================
-- restaurants policies
-- ============================================================
-- Public can read restaurant info
create policy "restaurants: public read"
  on public.restaurants for select
  using (true);

-- Only authenticated users can update restaurant settings
create policy "restaurants: auth update"
  on public.restaurants for update
  to authenticated
  using (true)
  with check (true);

-- ============================================================
-- categories policies
-- ============================================================
-- Public can read categories
create policy "categories: public read"
  on public.categories for select
  using (true);

-- Only authenticated users can insert/update/delete
create policy "categories: auth insert"
  on public.categories for insert
  to authenticated
  with check (true);

create policy "categories: auth update"
  on public.categories for update
  to authenticated
  using (true)
  with check (true);

create policy "categories: auth delete"
  on public.categories for delete
  to authenticated
  using (true);

-- ============================================================
-- products policies
-- ============================================================
-- Public can read ONLY available products
create policy "products: public read available"
  on public.products for select
  using (is_available = true);

-- Authenticated users can read ALL products (including unavailable)
create policy "products: auth read all"
  on public.products for select
  to authenticated
  using (true);

-- Only authenticated users can insert/update/delete
create policy "products: auth insert"
  on public.products for insert
  to authenticated
  with check (true);

create policy "products: auth update"
  on public.products for update
  to authenticated
  using (true)
  with check (true);

create policy "products: auth delete"
  on public.products for delete
  to authenticated
  using (true);

-- ============================================================
-- Note: Storage bucket RLS is configured in the Supabase
-- Dashboard > Storage > Policies.
-- See SETUP_GUIDE_TR.md for step-by-step instructions.
-- ============================================================
