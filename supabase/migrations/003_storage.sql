-- Storage bucket for product images and logos.
-- Public read (menu images), authenticated write.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'product-images', 'product-images', true, 2097152,
  array['image/webp','image/jpeg','image/png']
)
on conflict (id) do update
  set public = true,
      file_size_limit = 2097152,
      allowed_mime_types = array['image/webp','image/jpeg','image/png'];

drop policy if exists "product_images_public_read" on storage.objects;
drop policy if exists "product_images_admin_insert" on storage.objects;
drop policy if exists "product_images_admin_update" on storage.objects;
drop policy if exists "product_images_admin_delete" on storage.objects;

create policy "product_images_public_read" on storage.objects
  for select using (bucket_id = 'product-images');

create policy "product_images_admin_insert" on storage.objects
  for insert to authenticated with check (bucket_id = 'product-images');

create policy "product_images_admin_update" on storage.objects
  for update to authenticated using (bucket_id = 'product-images');

create policy "product_images_admin_delete" on storage.objects
  for delete to authenticated using (bucket_id = 'product-images');
