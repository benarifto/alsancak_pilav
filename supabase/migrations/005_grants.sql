-- Tablo erişim izinleri (RLS politikaları satır düzeyinde filtrelemeyi yine yapar)
grant usage on schema public to anon, authenticated;

-- Herkes menüyü okuyabilir
grant select on public.restaurants, public.categories, public.products to anon, authenticated;

-- Giriş yapmış yöneticiler düzenleyebilir
grant update on public.restaurants to authenticated;
grant insert, update, delete on public.categories, public.products to authenticated;
