# Kurulum Rehberi (Türkçe)

## 1. Supabase hesabı ve proje
1. https://supabase.com adresinde ücretsiz hesap açın.
2. **New project** ile proje oluşturun (bölge: Frankfurt önerilir). Veritabanı şifresini güvenli bir yere kaydedin.

## 2. Veritabanını kurma
Supabase panelinde **SQL Editor** > **New query** açın ve şu dosyaların içeriğini sırayla yapıştırıp **Run** deyin:
1. `supabase/migrations/001_schema.sql` (tablolar)
2. `supabase/migrations/002_rls.sql` (güvenlik kuralları)
3. `supabase/migrations/003_storage.sql` (görsel deposu: `product-images` bucket'ı ve kuralları)
4. İsteğe bağlı: `supabase/migrations/004_seed.sql` (örnek veri; canlıya geçmeden silebilirsiniz)

`001` dosyası bir restoran kaydı oluşturmuyorsa, seed dosyasını çalıştırın veya Table Editor'den `restaurants` tablosuna tek bir satır ekleyin (name: `Restoran Adı`, slug: `restoran`).

## 3. Yönetici hesapları
1. **Authentication > Sign In / Providers > Email** bölümünde **Allow new users to sign up** seçeneğini **kapatın** (kendi kendine kayıt kapalı olmalı).
2. **Authentication > Users > Add user > Create new user** ile iki hesabı (geliştirici ve restoran sahibi) e-posta + şifre ile oluşturun, **Auto Confirm User** işaretli olsun.
3. Şifreler yalnızca Supabase tarafından saklanır; veritabanına elle yazmayın.

## 4. Şifre sıfırlama
**Authentication > URL Configuration** içinde:
- **Site URL**: yayın adresiniz (örn. `https://siteniz.netlify.app`)
- **Redirect URLs**: `https://siteniz.netlify.app/**` ve `http://localhost:5173/**`

## 5. Ortam değişkenleri
**Project Settings > API** sayfasından **Project URL** ve **anon public** anahtarını alın.
```
copy .env.example .env
```
`.env` dosyasını doldurun:
```
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
VITE_PUBLIC_MENU_URL=https://siteniz.netlify.app/menu
```
> **service_role anahtarını asla** projeye veya GitHub'a koymayın. `.env` Git'e eklenmez.

## 6. Yerelde çalıştırma
```
npm install
npm run dev
```
Menü: http://localhost:5173/menu — Yönetim: http://localhost:5173/admin

## 7. Netlify'a yayınlama
1. Projeyi GitHub'a gönderin (`.env` dosyası hariç).
2. https://app.netlify.com > **Add new site > Import from Git** ile depoyu seçin.
3. Build komutu `npm run build`, yayın klasörü `dist` (`netlify.toml` zaten ayarlı).
4. **Site configuration > Environment variables** bölümüne üç `VITE_` değişkenini ekleyin; `VITE_PUBLIC_MENU_URL` son adresiniz + `/menu` olmalı.
5. Deploy edin. Adres belli olduktan sonra `VITE_PUBLIC_MENU_URL` değerini düzeltip yeniden yayınlayın.
6. Test: `/menu` açılıyor mu, `/admin` giriş sayfasına yönlendiriyor mu, sayfayı yenileyince 404 çıkmıyor mu?
7. **QR kodunu yayından sonra** admin > QR Kod sayfasından indirin; adres localhost olmamalı.

## 8. Özel alan adı (isteğe bağlı)
Netlify > **Domain management > Add a domain**. Alan adını satın almak sizin kararınızdır; Netlify'ın verdiği DNS ayarlarını alan adı sağlayıcınızda yapın. Adres değişirse `VITE_PUBLIC_MENU_URL`'i güncelleyip QR kodunu yeniden basın.
