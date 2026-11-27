# Manuel Test Listesi

Supabase kurulumundan sonra işaretleyin. (Henüz çalıştırılmadı: Supabase bağlantısı gerekir.)

- [ ] `.env` yokken uygulama net bir kurulum mesajı gösteriyor
- [ ] `/menu` açılıyor, yükleme/boş/hata durumları doğru
- [ ] `/admin` girişsizken `/login`'e yönlendiriyor
- [ ] Giriş / çıkış çalışıyor, sayfa yenilenince oturum korunuyor
- [ ] Şifre sıfırlama e-postası geliyor
- [ ] Ürün ekle / düzenle / sil (onay penceresi ile)
- [ ] Fiyat doğrulaması (negatif / boş reddedilir)
- [ ] Görsel yükleme: yanlış tür ve büyük dosya reddedilir; WebP olarak yüklenir
- [ ] Ürünü "mevcut değil" yapınca `/menu`'da görünmüyor
- [ ] Ürünsüz kategori `/menu`'da görünmüyor
- [ ] Kategori ekle / yeniden adlandır / sırala / ürünlü kategori silme uyarısı
- [ ] Ayarlar: isim, logo, telefon, adres, saatler kaydediliyor ve menüde görünüyor
- [ ] QR sayfası: doğru üretim URL'si (localhost değil), PNG ve SVG iniyor, A4 yazdırma önizlemesi 4 kopya + "Menümüzü görüntülemek için okutun."
- [ ] Telefonla QR okutma çalışıyor
- [ ] Anonim kullanıcı ile ekleme/güncelleme/silme reddediliyor (RLS)
- [ ] 360px, 768px, 1280px genişliklerde düzen bozulmuyor
- [ ] Tarayıcı konsolunda hata yok
- [ ] Netlify'da `/menu` ve `/admin/products` yenilenince 404 vermiyor
