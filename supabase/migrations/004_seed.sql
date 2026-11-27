-- ============================================================
-- Migration 004: Seed Data (Optional Demo Data)
-- Run AFTER 002_rls.sql
-- ============================================================

-- Get the restaurant id
do $$
declare
  rest_id uuid;
  cat_corbalar uuid;
  cat_pilav uuid;
  cat_ana uuid;
  cat_tatli uuid;
begin
  select id into rest_id from public.restaurants where slug = 'restoran' limit 1;

  -- Update restaurant info to demo values
  update public.restaurants set
    name        = 'Ev Yemekleri',
    description = 'Taze ve lezzetli ev yemekleri. Annenizin mutfağından sofraya.',
    phone       = '+90 555 123 45 67',
    address     = 'Alsancak, İzmir',
    opening_hours = '{"Pazartesi":"10:00-21:00","Salı":"10:00-21:00","Çarşamba":"10:00-21:00","Perşembe":"10:00-21:00","Cuma":"10:00-22:00","Cumartesi":"11:00-22:00","Pazar":"Kapalı"}'::jsonb
  where id = rest_id;

  -- Categories
  insert into public.categories (restaurant_id, name, display_order)
  values (rest_id, 'Çorbalar', 1) returning id into cat_corbalar;

  insert into public.categories (restaurant_id, name, display_order)
  values (rest_id, 'Pilav & Makarna', 2) returning id into cat_pilav;

  insert into public.categories (restaurant_id, name, display_order)
  values (rest_id, 'Ana Yemekler', 3) returning id into cat_ana;

  insert into public.categories (restaurant_id, name, display_order)
  values (rest_id, 'Tatlılar', 4) returning id into cat_tatli;

  -- Products: Çorbalar
  insert into public.products (restaurant_id, category_id, name, description, price, is_available, display_order)
  values
    (rest_id, cat_corbalar, 'Mercimek Çorbası', 'Klasik kırmızı mercimek çorbası, nane ve kırmızı biber ile servis edilir.', 60, true, 1),
    (rest_id, cat_corbalar, 'Ezogelin Çorbası', 'Kırmızı mercimek, bulgur ve baharat ile pişirilmiş geleneksel çorba.', 65, true, 2),
    (rest_id, cat_corbalar, 'Tarhana Çorbası', 'Ev yapımı tarhana ile hazırlanan nefis çorba.', 70, true, 3);

  -- Products: Pilav
  insert into public.products (restaurant_id, category_id, name, description, price, is_available, display_order)
  values
    (rest_id, cat_pilav, 'Tereyağlı Pilav', 'Buharda pişirilmiş tereyağlı pirinç pilavı.', 50, true, 1),
    (rest_id, cat_pilav, 'Nohutlu Pilav', 'Nohut ve pirinçle hazırlanan doyurucu pilav.', 65, true, 2),
    (rest_id, cat_pilav, 'Erişte', 'El yapımı erişte, tereyağı ve peynir ile.', 75, true, 3);

  -- Products: Ana Yemekler
  insert into public.products (restaurant_id, category_id, name, description, price, is_available, display_order)
  values
    (rest_id, cat_ana, 'Kuru Fasulye', 'Geleneksel kuru fasulye, pirinç pilavı ile servis edilir.', 120, true, 1),
    (rest_id, cat_ana, 'İzmir Köfte', 'Patates ve biber ile fırında pişirilmiş İzmir usulü köfte.', 150, true, 2),
    (rest_id, cat_ana, 'Etli Nohut', 'Dana eti ve nohut ile hazırlanan doyurucu yemek.', 160, true, 3),
    (rest_id, cat_ana, 'Imam Bayıldı', 'Fırında pişirilmiş patlıcan dolması, zeytinyağlı.', 130, true, 4),
    (rest_id, cat_ana, 'Zeytinyağlı Enginar', 'Mevsim sebzeleri ile hazırlanan enginar.', 140, false, 5);

  -- Products: Tatlılar
  insert into public.products (restaurant_id, category_id, name, description, price, is_available, display_order)
  values
    (rest_id, cat_tatli, 'Sütlaç', 'Fırında üstü kızartılmış sütlaç.', 70, true, 1),
    (rest_id, cat_tatli, 'Kabak Tatlısı', 'Kabak tatlısı, üzerine ceviz ile servis edilir.', 65, true, 2),
    (rest_id, cat_tatli, 'Aşure', 'Geleneksel aşure, nar taneleri ve fındık ile.', 75, true, 3);

end $$;
