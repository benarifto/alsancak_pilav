-- ============================================================
-- Migration 001: Schema
-- Run this in the Supabase SQL Editor
-- ============================================================

-- Enable UUID extension
create extension if not exists "pgcrypto";

-- ============================================================
-- Table: restaurants
-- ============================================================
create table if not exists public.restaurants (
  id            uuid primary key default gen_random_uuid(),
  name          text not null default 'Restoran Adı',
  slug          text not null unique default 'restoran',
  description   text,
  logo_url      text,
  phone         text,
  address       text,
  opening_hours jsonb,       -- { "Pazartesi": "09:00-22:00", ... }
  social_links  jsonb,       -- { "instagram": "...", "facebook": "..." }
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ============================================================
-- Table: categories
-- ============================================================
create table if not exists public.categories (
  id             uuid primary key default gen_random_uuid(),
  restaurant_id  uuid not null references public.restaurants(id) on delete cascade,
  name           text not null,
  display_order  integer not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index if not exists idx_categories_restaurant_id on public.categories(restaurant_id);
create index if not exists idx_categories_display_order on public.categories(restaurant_id, display_order);

-- ============================================================
-- Table: products
-- ============================================================
create table if not exists public.products (
  id             uuid primary key default gen_random_uuid(),
  restaurant_id  uuid not null references public.restaurants(id) on delete cascade,
  category_id    uuid not null references public.categories(id) on delete restrict,
  name           text not null,
  description    text,
  price          numeric(10,2) not null default 0 check (price >= 0),
  image_url      text,
  is_available   boolean not null default true,
  display_order  integer not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index if not exists idx_products_restaurant_id on public.products(restaurant_id);
create index if not exists idx_products_category_id on public.products(category_id);
create index if not exists idx_products_is_available on public.products(restaurant_id, is_available);
create index if not exists idx_products_display_order on public.products(category_id, display_order);

-- ============================================================
-- Function: auto-update updated_at column
-- ============================================================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace trigger restaurants_updated_at
  before update on public.restaurants
  for each row execute procedure public.set_updated_at();

create or replace trigger categories_updated_at
  before update on public.categories
  for each row execute procedure public.set_updated_at();

create or replace trigger products_updated_at
  before update on public.products
  for each row execute procedure public.set_updated_at();

-- ============================================================
-- Insert default restaurant row (single-restaurant architecture)
-- ============================================================
insert into public.restaurants (name, slug)
values ('Restoran Adı', 'restoran')
on conflict (slug) do nothing;
