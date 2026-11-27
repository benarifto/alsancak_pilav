<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useToastStore } from '@/stores/toast.js'
import ProductFormModal from '@/components/admin/ProductFormModal.vue'
import ConfirmDialog from '@/components/ui/ConfirmDialog.vue'
import { formatPrice } from '@/lib/formatters.js'
import { Plus, Search, Pencil, Trash2, Eye, EyeOff, Package, Image as ImageIcon } from '@lucide/vue'

const toast      = useToastStore()
const products   = ref([])
const categories = ref([])
const loading    = ref(true)

// Modal / dialog state
const showModal    = ref(false)
const editProduct  = ref(null)
const deleteTarget = ref(null)
const showConfirm  = ref(false)

// Filters
const searchQuery      = ref('')
const filterCategory   = ref('')
const filterAvailability = ref('')

const filtered = computed(() => {
  return products.value.filter(p => {
    const matchSearch = !searchQuery.value ||
      p.name.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchCat = !filterCategory.value || p.category_id === filterCategory.value
    const matchAvail = filterAvailability.value === ''
      ? true
      : filterAvailability.value === 'active'
        ? p.is_available
        : !p.is_available
    return matchSearch && matchCat && matchAvail
  })
})

function categoryName(id) {
  return categories.value.find(c => c.id === id)?.name ?? '—'
}

async function fetchData() {
  loading.value = true
  const [{ data: prods }, { data: cats }] = await Promise.all([
    supabase.from('products').select('*').order('display_order'),
    supabase.from('categories').select('*').order('display_order'),
  ])
  products.value   = prods || []
  categories.value = cats  || []
  loading.value    = false
}

function openCreate() { editProduct.value = null; showModal.value = true }
function openEdit(p)  { editProduct.value = p;    showModal.value = true }

function onModalSaved() {
  showModal.value = false
  fetchData()
}

function confirmDelete(p) {
  deleteTarget.value = p
  showConfirm.value  = true
}

async function handleDelete() {
  if (!deleteTarget.value) return
  showConfirm.value = false
  const { error } = await supabase.from('products').delete().eq('id', deleteTarget.value.id)
  if (error) {
    toast.error('Ürün silinemedi: ' + error.message)
  } else {
    toast.success('Ürün silindi.')
    fetchData()
  }
  deleteTarget.value = null
}

async function toggleAvailability(p) {
  const { error } = await supabase
    .from('products')
    .update({ is_available: !p.is_available })
    .eq('id', p.id)
  if (error) {
    toast.error('Durum güncellenemedi.')
  } else {
    p.is_available = !p.is_available
    toast.success(p.is_available ? 'Ürün aktife alındı.' : 'Ürün pasife alındı.')
  }
}

onMounted(fetchData)
</script>

<template>
  <div class="p-6 max-w-5xl mx-auto space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between gap-4 flex-wrap">
      <div>
        <div class="flex items-center gap-3 mb-1">
          <Package class="w-5 h-5 text-terracotta-600" />
          <h1 class="font-display text-2xl font-bold text-brown-800">Ürünler</h1>
        </div>
        <p class="text-brown-500 text-sm">{{ products.length }} ürün</p>
      </div>
      <button
        id="add-product-btn"
        @click="openCreate"
        class="flex items-center gap-2 px-4 py-2.5 bg-terracotta-600 text-white rounded-xl text-sm font-semibold hover:bg-terracotta-500 transition-colors shadow-sm"
      >
        <Plus class="w-4 h-4" /> Yeni Ürün
      </button>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3">
      <!-- Search -->
      <div class="relative flex-1 min-w-48">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-brown-400" />
        <input
          v-model="searchQuery"
          type="search"
          placeholder="Ürün ara…"
          class="w-full pl-9 pr-4 py-2.5 rounded-xl border border-brown-200 bg-white text-sm text-brown-800 focus:outline-none focus:border-terracotta-400 transition-colors"
        />
      </div>

      <!-- Category filter -->
      <select
        v-model="filterCategory"
        class="px-4 py-2.5 rounded-xl border border-brown-200 bg-white text-sm text-brown-700 focus:outline-none focus:border-terracotta-400 transition-colors"
      >
        <option value="">Tüm Kategoriler</option>
        <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
      </select>

      <!-- Availability filter -->
      <select
        v-model="filterAvailability"
        class="px-4 py-2.5 rounded-xl border border-brown-200 bg-white text-sm text-brown-700 focus:outline-none focus:border-terracotta-400 transition-colors"
      >
        <option value="">Tüm Durumlar</option>
        <option value="active">Aktif</option>
        <option value="inactive">Pasif</option>
      </select>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="space-y-3">
      <div v-for="i in 5" :key="i" class="skeleton h-16 rounded-xl" />
    </div>

    <!-- Empty state -->
    <div
      v-else-if="filtered.length === 0"
      class="text-center py-16 text-brown-400"
    >
      <Package class="w-12 h-12 mx-auto mb-3 opacity-30" />
      <p class="font-medium">{{ products.length === 0 ? 'Henüz ürün eklenmedi.' : 'Aramanıza uygun ürün bulunamadı.' }}</p>
      <button
        v-if="products.length === 0"
        @click="openCreate"
        class="mt-4 text-sm text-terracotta-600 hover:underline"
      >
        İlk ürünü ekle →
      </button>
    </div>

    <!-- Product list -->
    <div v-else class="bg-white rounded-2xl border border-brown-100 shadow-sm overflow-hidden">
      <div
        v-for="(product, idx) in filtered"
        :key="product.id"
        class="flex items-center gap-4 px-4 py-3 hover:bg-cream-50 transition-colors"
        :class="idx < filtered.length - 1 ? 'border-b border-brown-100' : ''"
      >
        <!-- Thumbnail -->
        <div class="w-12 h-12 rounded-xl overflow-hidden bg-cream-200 shrink-0">
          <img
            v-if="product.image_url"
            :src="product.image_url"
            :alt="product.name"
            class="w-full h-full object-cover"
          />
          <div v-else class="w-full h-full flex items-center justify-center">
            <ImageIcon class="w-5 h-5 text-brown-200" />
          </div>
        </div>

        <!-- Info -->
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2 flex-wrap">
            <p class="text-sm font-semibold text-brown-800 truncate">{{ product.name }}</p>
            <span
              class="text-xs px-2 py-0.5 rounded-full font-medium"
              :class="product.is_available
                ? 'bg-olive-100 text-olive-700'
                : 'bg-terracotta-100 text-terracotta-700'"
            >
              {{ product.is_available ? 'Aktif' : 'Pasif' }}
            </span>
          </div>
          <p class="text-xs text-brown-400 mt-0.5">
            {{ categoryName(product.category_id) }} &bull;
            <span class="font-semibold text-brown-600">{{ formatPrice(product.price) }}</span>
          </p>
        </div>

        <!-- Actions -->
        <div class="flex items-center gap-1 shrink-0">
          <button
            :id="`toggle-${product.id}`"
            @click="toggleAvailability(product)"
            class="p-2 rounded-lg hover:bg-cream-100 text-brown-400 hover:text-brown-700 transition-colors"
            :aria-label="product.is_available ? 'Pasife al' : 'Aktife al'"
            :title="product.is_available ? 'Pasife al' : 'Aktife al'"
          >
            <EyeOff v-if="product.is_available" class="w-4 h-4" />
            <Eye v-else class="w-4 h-4" />
          </button>
          <button
            :id="`edit-${product.id}`"
            @click="openEdit(product)"
            class="p-2 rounded-lg hover:bg-cream-100 text-brown-400 hover:text-brown-700 transition-colors"
            aria-label="Düzenle"
          >
            <Pencil class="w-4 h-4" />
          </button>
          <button
            :id="`delete-${product.id}`"
            @click="confirmDelete(product)"
            class="p-2 rounded-lg hover:bg-terracotta-100 text-brown-400 hover:text-terracotta-600 transition-colors"
            aria-label="Sil"
          >
            <Trash2 class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Product Form Modal -->
  <ProductFormModal
    v-if="showModal"
    :product="editProduct"
    :categories="categories"
    @saved="onModalSaved"
    @close="showModal = false"
  />

  <!-- Delete Confirm -->
  <ConfirmDialog
    v-if="showConfirm"
    title="Ürünü Sil"
    :message="`'${deleteTarget?.name}' ürününü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.`"
    confirm-text="Evet, Sil"
    @confirm="handleDelete"
    @cancel="showConfirm = false; deleteTarget = null"
  />
</template>
