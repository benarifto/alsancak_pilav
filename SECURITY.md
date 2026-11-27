# Güvenlik Notları

- **Kimlik doğrulama:** Supabase Auth. Yönetici hesapları panelden elle oluşturulur; self-signup kapatılmalıdır (SETUP_GUIDE_TR.md, Adım 3).
- **RLS:** `restaurants`, `categories`, `products` tablolarında etkin. Anonim kullanıcılar yalnızca okuyabilir (ürünlerde yalnızca `is_available = true`). Yazma işlemleri yalnızca `authenticated` rolüne açıktır.
- **Storage:** `product-images` herkese okuma, yalnızca giriş yapmışlara yazma/silme; 2 MB ve resim türü sınırı (`003_storage.sql`).
- **Frontend yönlendirme koruması** sadece kolaylıktır; asıl koruma RLS'tir.
- **Anahtarlar:** Yalnızca anon anahtarı kullanılır (herkese açık olması tasarım gereğidir, RLS korur). `service_role` anahtarı hiçbir yerde kullanılmaz. `.env` `.gitignore` içindedir.
- Not: Girişli herhangi bir kullanıcı yönetici sayılır; bu yüzden sign-up kapalı olmalıdır.
