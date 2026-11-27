<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useToastStore } from '@/stores/toast.js'
import ImageUploader from '@/components/ui/ImageUploader.vue'
import { Settings, Save } from '@lucide/vue'

const toast   = useToastStore()
const loading = ref(true)
const saving  = ref(false)

const restId  = ref(null)
const form    = ref({
  name:          '',
  description:   '',
  phone:         '',
  address:       '',
  logo_url:      null,
  social_links:  { instagram: '', facebook: '', twitter: '' },
  opening_hours: {
    Pazartesi: '', Salı: '', Çarşamba: '', Perşembe: '',
    Cuma: '', Cumartesi: '', Pazar: '',
  },
})

onMounted(async () => {
  const { data } = await supabase.from('restaurants').select('*').limit(1).single()
  if (data) {
    restId.value = data.id
    form.value.name        = data.name        || ''
    form.value.description = data.description || ''
    form.value.phone       = data.phone       || ''
    form.value.address     = data.address     || ''
    form.value.logo_url    = data.logo_url    || null
    form.value.social_links = {
      instagram: data.social_links?.instagram || '',
      facebook:  data.social_links?.facebook  || '',
      twitter:   data.social_links?.twitter   || '',
    }
    if (data.opening_hours) {
      Object.assign(form.value.opening_hours, data.opening_hours)
    }
  }
  loading.value = false
})

async function handleSave() {
  if (!restId.value) return
  saving.value = true
  try {
    const { error } = await supabase.from('restaurants').update({
      name:          form.value.name.trim(),
      description:   form.value.description.trim() || null,
      phone:         form.value.phone.trim() || null,
      address:       form.value.address.trim() || null,
      logo_url:      form.value.logo_url || null,
      social_links:  form.value.social_links,
      opening_hours: form.value.opening_hours,
    }).eq('id', restId.value)

    if (error) throw error
    toast.success('Ayarlar kaydedildi.')
  } catch (err) {
    toast.error('Kaydedilemedi: ' + err.message)
  } finally {
    saving.value = false
  }
}

const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar']
</script>

<template>
  <div class="p-6 max-w-3xl mx-auto space-y-6">
    <div>
      <div class="flex items-center gap-3 mb-1">
        <Settings class="w-5 h-5 text-terracotta-600" />
        <h1 class="font-display text-2xl font-bold text-brown-800">Restoran Ayarları</h1>
      </div>
      <p class="text-brown-500 text-sm">Müşterilere gösterilecek bilgileri güncelleyin</p>
    </div>

    <div v-if="loading" class="space-y-4">
      <div v-for="i in 6" :key="i" class="skeleton h-12 rounded-xl" />
    </div>

    <form v-else @submit.prevent="handleSave" class="space-y-6">
      <!-- Logo -->
      <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-5">
        <h2 class="text-sm font-semibold text-brown-700 mb-4">Logo</h2>
        <ImageUploader
          bucket="product-images"
          prefix="logos"
          :current-url="form.logo_url"
          @uploaded="url => form.logo_url = url"
        />
      </div>

      <!-- Basic info -->
      <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-5 space-y-4">
        <h2 class="text-sm font-semibold text-brown-700">Temel Bilgiler</h2>

        <div>
          <label for="rest-name" class="block text-sm font-medium text-brown-700 mb-1.5">
            Restoran Adı <span class="text-terracotta-600">*</span>
          </label>
          <input
            id="rest-name"
            v-model="form.name"
            type="text"
            required
            class="w-full px-4 py-2.5 rounded-xl border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors"
          />
        </div>

        <div>
          <label for="rest-desc" class="block text-sm font-medium text-brown-700 mb-1.5">Kısa Açıklama</label>
          <textarea
            id="rest-desc"
            v-model="form.description"
            rows="3"
            placeholder="Restoranınız hakkında kısa bir açıklama…"
            class="w-full px-4 py-2.5 rounded-xl border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors resize-none"
          />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label for="rest-phone" class="block text-sm font-medium text-brown-700 mb-1.5">Telefon</label>
            <input
              id="rest-phone"
              v-model="form.phone"
              type="tel"
              placeholder="+90 555 000 00 00"
              class="w-full px-4 py-2.5 rounded-xl border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors"
            />
          </div>
          <div>
            <label for="rest-address" class="block text-sm font-medium text-brown-700 mb-1.5">Adres</label>
            <input
              id="rest-address"
              v-model="form.address"
              type="text"
              placeholder="Mahalle, İlçe, Şehir"
              class="w-full px-4 py-2.5 rounded-xl border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors"
            />
          </div>
        </div>
      </div>

      <!-- Social links -->
      <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-5 space-y-4">
        <h2 class="text-sm font-semibold text-brown-700">Sosyal Medya</h2>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div v-for="platform in ['instagram', 'facebook', 'twitter']" :key="platform">
            <label :for="`social-${platform}`" class="block text-xs font-medium text-brown-600 mb-1 capitalize">{{ platform }}</label>
            <input
              :id="`social-${platform}`"
              v-model="form.social_links[platform]"
              type="url"
              :placeholder="`https://${platform}.com/…`"
              class="w-full px-3 py-2 rounded-lg border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors"
            />
          </div>
        </div>
      </div>

      <!-- Opening hours -->
      <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-5 space-y-3">
        <h2 class="text-sm font-semibold text-brown-700 mb-1">Çalışma Saatleri</h2>
        <p class="text-xs text-brown-400">Boş bırakılan günler menüde gösterilmez.</p>
        <div class="space-y-2.5">
          <div v-for="day in days" :key="day" class="flex items-center gap-3">
            <label :for="`hour-${day}`" class="w-24 text-sm text-brown-700 shrink-0">{{ day }}</label>
            <input
              :id="`hour-${day}`"
              v-model="form.opening_hours[day]"
              type="text"
              placeholder="10:00-22:00 veya Kapalı"
              class="flex-1 px-3 py-2 rounded-lg border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors"
            />
          </div>
        </div>
      </div>

      <!-- Save button -->
      <div class="flex justify-end">
        <button
          id="save-settings"
          type="submit"
          :disabled="saving"
          class="flex items-center gap-2 px-6 py-3 bg-terracotta-600 text-white rounded-xl text-sm font-semibold hover:bg-terracotta-500 disabled:opacity-60 transition-colors shadow-sm"
        >
          <Save class="w-4 h-4" />
          {{ saving ? 'Kaydediliyor…' : 'Kaydet' }}
        </button>
      </div>
    </form>
  </div>
</template>
