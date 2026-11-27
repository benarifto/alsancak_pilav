<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { supabase } from '@/lib/supabase.js'
import { Package, Tags, Settings, QrCode, CheckCircle, XCircle, LayoutDashboard } from '@lucide/vue'

const stats   = ref({ total: 0, available: 0, unavailable: 0, categories: 0 })
const loading = ref(true)

const quickLinks = [
  { to: '/admin/products',   label: 'Ürün Yönetimi',      icon: Package,         desc: 'Ürün ekle, düzenle, sil' },
  { to: '/admin/categories', label: 'Kategori Yönetimi',   icon: Tags,            desc: 'Kategorileri düzenle' },
  { to: '/admin/settings',   label: 'Restoran Ayarları',   icon: Settings,        desc: 'Bilgileri güncelle' },
  { to: '/admin/qr',         label: 'QR Kod',              icon: QrCode,          desc: 'QR kod oluştur ve indir' },
]

onMounted(async () => {
  try {
    const [{ count: total }, { count: available }, { count: categories }] = await Promise.all([
      supabase.from('products').select('*', { count: 'exact', head: true }),
      supabase.from('products').select('*', { count: 'exact', head: true }).eq('is_available', true),
      supabase.from('categories').select('*', { count: 'exact', head: true }),
    ])
    stats.value = {
      total:       total ?? 0,
      available:   available ?? 0,
      unavailable: (total ?? 0) - (available ?? 0),
      categories:  categories ?? 0,
    }
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="p-6 max-w-5xl mx-auto space-y-8">
    <!-- Page header -->
    <div>
      <div class="flex items-center gap-3 mb-1">
        <LayoutDashboard class="w-5 h-5 text-terracotta-600" />
        <h1 class="font-display text-2xl font-bold text-brown-800">Genel Bakış</h1>
      </div>
      <p class="text-brown-500 text-sm">Menünüzün anlık özeti</p>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <!-- Total products -->
      <div class="bg-white rounded-2xl p-5 border border-brown-100 shadow-sm">
        <div class="text-3xl font-display font-bold text-brown-800 mb-1">
          <span v-if="loading" class="skeleton w-10 h-8 inline-block" />
          <span v-else>{{ stats.total }}</span>
        </div>
        <p class="text-sm text-brown-500">Toplam Ürün</p>
      </div>

      <!-- Available -->
      <div class="bg-white rounded-2xl p-5 border border-olive-100 shadow-sm">
        <div class="text-3xl font-display font-bold text-olive-600 mb-1">
          <span v-if="loading" class="skeleton w-10 h-8 inline-block" />
          <span v-else>{{ stats.available }}</span>
        </div>
        <div class="flex items-center gap-1.5">
          <CheckCircle class="w-3.5 h-3.5 text-olive-500" />
          <p class="text-sm text-brown-500">Aktif Ürün</p>
        </div>
      </div>

      <!-- Unavailable -->
      <div class="bg-white rounded-2xl p-5 border border-terracotta-100 shadow-sm">
        <div class="text-3xl font-display font-bold text-terracotta-600 mb-1">
          <span v-if="loading" class="skeleton w-10 h-8 inline-block" />
          <span v-else>{{ stats.unavailable }}</span>
        </div>
        <div class="flex items-center gap-1.5">
          <XCircle class="w-3.5 h-3.5 text-terracotta-500" />
          <p class="text-sm text-brown-500">Pasif Ürün</p>
        </div>
      </div>

      <!-- Categories -->
      <div class="bg-white rounded-2xl p-5 border border-brown-100 shadow-sm">
        <div class="text-3xl font-display font-bold text-brown-800 mb-1">
          <span v-if="loading" class="skeleton w-10 h-8 inline-block" />
          <span v-else>{{ stats.categories }}</span>
        </div>
        <p class="text-sm text-brown-500">Kategori</p>
      </div>
    </div>

    <!-- Quick links -->
    <div>
      <h2 class="font-semibold text-brown-700 mb-4">Hızlı Erişim</h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <RouterLink
          v-for="link in quickLinks"
          :key="link.to"
          :to="link.to"
          class="group flex items-center gap-4 bg-white rounded-xl p-4 border border-brown-100 hover:border-terracotta-200 hover:shadow-sm transition-all"
        >
          <div class="w-10 h-10 rounded-xl bg-cream-100 group-hover:bg-terracotta-100 flex items-center justify-center transition-colors shrink-0">
            <component :is="link.icon" class="w-5 h-5 text-brown-500 group-hover:text-terracotta-600 transition-colors" />
          </div>
          <div>
            <p class="text-sm font-semibold text-brown-800">{{ link.label }}</p>
            <p class="text-xs text-brown-400">{{ link.desc }}</p>
          </div>
        </RouterLink>
      </div>
    </div>
  </div>
</template>
