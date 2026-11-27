<script setup>
import { ref, watch, computed } from 'vue'
import { X } from '@lucide/vue'
import { supabase } from '@/lib/supabase.js'
import { useToastStore } from '@/stores/toast.js'
import ImageUploader from '@/components/ui/ImageUploader.vue'

const props = defineProps({
  product:    { type: Object, default: null }, // null = create mode
  categories: { type: Array, default: () => [] },
})

const emit = defineEmits(['saved', 'close'])
const toast = useToastStore()

const isEdit = computed(() => !!props.product?.id)

// Form state
const form = ref({
  name:          '',
  description:   '',
  price:         '',
  category_id:   '',
  is_available:  true,
  display_order: 0,
  image_url:     null,
})

const saving   = ref(false)
const errors   = ref({})

// Populate form when editing
watch(() => props.product, (p) => {
  if (p) {
    form.value = {
      name:          p.name          || '',
      description:   p.description   || '',
      price:         p.price         != null ? String(p.price) : '',
      category_id:   p.category_id   || '',
      is_available:  p.is_available  ?? true,
      display_order: p.display_order ?? 0,
      image_url:     p.image_url     || null,
    }
  } else {
    form.value = { name: '', description: '', price: '', category_id: '', is_available: true, display_order: 0, image_url: null }
  }
}, { immediate: true })

function validate() {
  errors.value = {}
  if (!form.value.name.trim()) errors.value.name = 'Ürün adı zorunludur.'
  if (form.value.price === '' || isNaN(parseFloat(form.value.price)) || parseFloat(form.value.price) < 0) {
    errors.value.price = 'Geçerli bir fiyat girin (0 veya üzeri).'
  }
  if (!form.value.category_id) errors.value.category_id = 'Lütfen bir kategori seçin.'
  return Object.keys(errors.value).length === 0
}

async function handleSave() {
  if (!validate()) return

  saving.value = true
  try {
    // Get restaurant_id
    const { data: rest } = await supabase.from('restaurants').select('id').limit(1).single()
    const restaurant_id = rest?.id

    const payload = {
      name:          form.value.name.trim(),
      description:   form.value.description.trim() || null,
      price:         parseFloat(form.value.price),
      category_id:   form.value.category_id,
      is_available:  form.value.is_available,
      display_order: parseInt(form.value.display_order) || 0,
      image_url:     form.value.image_url || null,
      restaurant_id,
    }

    if (isEdit.value) {
      const { error } = await supabase.from('products').update(payload).eq('id', props.product.id)
      if (error) throw error
      toast.success('Ürün güncellendi.')
    } else {
      const { error } = await supabase.from('products').insert(payload)
      if (error) throw error
      toast.success('Ürün eklendi.')
    }

    emit('saved')
  } catch (err) {
    toast.error('Kayıt başarısız: ' + (err.message || 'Bilinmeyen hata.'))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      <!-- Overlay -->
      <div class="absolute inset-0 bg-brown-800/60 backdrop-blur-sm" @click="emit('close')" />

      <!-- Modal -->
      <div class="relative bg-cream-50 rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] flex flex-col z-10">
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-brown-100 shrink-0">
          <h2 class="font-display text-lg font-semibold text-brown-800">
            {{ isEdit ? 'Ürünü Düzenle' : 'Yeni Ürün Ekle' }}
          </h2>
          <button @click="emit('close')" class="p-1.5 rounded-lg hover:bg-cream-200 transition-colors">
            <X class="w-5 h-5 text-brown-500" />
          </button>
        </div>

        <!-- Scrollable body -->
        <div class="overflow-y-auto flex-1 px-6 py-5 space-y-4">
          <!-- Image -->
          <div>
            <label class="block text-sm font-medium text-brown-700 mb-2">Fotoğraf</label>
            <ImageUploader
              bucket="product-images"
              prefix="products"
              :current-url="form.image_url"
              @uploaded="url => form.image_url = url"
            />
          </div>

          <!-- Name -->
          <div>
            <label for="product-name" class="block text-sm font-medium text-brown-700 mb-1.5">
              Ürün Adı <span class="text-terracotta-600">*</span>
            </label>
            <input
              id="product-name"
              v-model="form.name"
              type="text"
              placeholder="ör. Mercimek Çorbası"
              class="w-full px-4 py-2.5 rounded-lg border text-brown-800 text-sm bg-white focus:outline-none focus:border-terracotta-400 transition-colors"
              :class="errors.name ? 'border-terracotta-400' : 'border-brown-200'"
            />
            <p v-if="errors.name" class="text-xs text-terracotta-600 mt-1">{{ errors.name }}</p>
          </div>

          <!-- Description -->
          <div>
            <label for="product-desc" class="block text-sm font-medium text-brown-700 mb-1.5">Açıklama</label>
            <textarea
              id="product-desc"
              v-model="form.description"
              rows="3"
              placeholder="Ürün hakkında kısa bir açıklama…"
              class="w-full px-4 py-2.5 rounded-lg border border-brown-200 text-brown-800 text-sm bg-white focus:outline-none focus:border-terracotta-400 transition-colors resize-none"
            />
          </div>

          <!-- Price + Category row -->
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label for="product-price" class="block text-sm font-medium text-brown-700 mb-1.5">
                Fiyat (TL) <span class="text-terracotta-600">*</span>
              </label>
              <input
                id="product-price"
                v-model="form.price"
                type="number"
                min="0"
                step="0.01"
                placeholder="0"
                class="w-full px-4 py-2.5 rounded-lg border text-brown-800 text-sm bg-white focus:outline-none focus:border-terracotta-400 transition-colors"
                :class="errors.price ? 'border-terracotta-400' : 'border-brown-200'"
              />
              <p v-if="errors.price" class="text-xs text-terracotta-600 mt-1">{{ errors.price }}</p>
            </div>

            <div>
              <label for="product-category" class="block text-sm font-medium text-brown-700 mb-1.5">
                Kategori <span class="text-terracotta-600">*</span>
              </label>
              <select
                id="product-category"
                v-model="form.category_id"
                class="w-full px-4 py-2.5 rounded-lg border text-brown-800 text-sm bg-white focus:outline-none focus:border-terracotta-400 transition-colors"
                :class="errors.category_id ? 'border-terracotta-400' : 'border-brown-200'"
              >
                <option value="" disabled>Seç…</option>
                <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
              </select>
              <p v-if="errors.category_id" class="text-xs text-terracotta-600 mt-1">{{ errors.category_id }}</p>
            </div>
          </div>

          <!-- Display order + Availability -->
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label for="product-order" class="block text-sm font-medium text-brown-700 mb-1.5">Sıra</label>
              <input
                id="product-order"
                v-model="form.display_order"
                type="number"
                min="0"
                class="w-full px-4 py-2.5 rounded-lg border border-brown-200 text-brown-800 text-sm bg-white focus:outline-none focus:border-terracotta-400 transition-colors"
              />
            </div>
            <div class="flex flex-col justify-end pb-1">
              <label class="flex items-center gap-3 cursor-pointer">
                <div class="relative">
                  <input
                    id="product-available"
                    v-model="form.is_available"
                    type="checkbox"
                    class="sr-only peer"
                  />
                  <div class="w-10 h-6 rounded-full bg-brown-200 peer-checked:bg-olive-500 transition-colors" />
                  <div class="absolute top-1 left-1 w-4 h-4 rounded-full bg-white shadow transition-transform peer-checked:translate-x-4" />
                </div>
                <span class="text-sm font-medium text-brown-700">
                  {{ form.is_available ? 'Aktif' : 'Pasif' }}
                </span>
              </label>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="flex gap-3 px-6 py-4 border-t border-brown-100 shrink-0 justify-end">
          <button
            @click="emit('close')"
            class="px-5 py-2.5 rounded-lg text-sm font-medium text-brown-600 border border-brown-200 hover:bg-cream-100 transition-colors"
          >
            İptal
          </button>
          <button
            id="product-save"
            @click="handleSave"
            :disabled="saving"
            class="px-5 py-2.5 rounded-lg text-sm font-medium text-white bg-terracotta-600 hover:bg-terracotta-500 disabled:opacity-60 transition-colors min-w-24"
          >
            <span v-if="saving" class="flex items-center gap-2">
              <span class="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              Kaydediliyor…
            </span>
            <span v-else>{{ isEdit ? 'Güncelle' : 'Kaydet' }}</span>
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
