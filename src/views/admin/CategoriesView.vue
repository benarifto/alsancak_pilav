<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useToastStore } from '@/stores/toast.js'
import ConfirmDialog from '@/components/ui/ConfirmDialog.vue'
import { Tags, Plus, Pencil, Trash2, Check, X, GripVertical } from '@lucide/vue'

const toast      = useToastStore()
const categories = ref([])
const loading    = ref(true)

// Add new category
const newName    = ref('')
const addLoading = ref(false)

// Edit state
const editId   = ref(null)
const editName = ref('')

// Delete
const deleteTarget  = ref(null)
const showConfirm   = ref(false)
const deleteWarning = ref('')

async function fetchCategories() {
  loading.value = true
  const { data } = await supabase.from('categories').select('*').order('display_order')
  categories.value = data || []
  loading.value = false
}

async function handleAdd() {
  if (!newName.value.trim()) return
  addLoading.value = true
  try {
    const { data: rest } = await supabase.from('restaurants').select('id').limit(1).single()
    const maxOrder = categories.value.length > 0
      ? Math.max(...categories.value.map(c => c.display_order)) + 1
      : 0

    const { error } = await supabase.from('categories').insert({
      name: newName.value.trim(),
      restaurant_id: rest.id,
      display_order: maxOrder,
    })
    if (error) throw error
    newName.value = ''
    toast.success('Kategori eklendi.')
    fetchCategories()
  } catch (err) {
    toast.error('Eklenemedi: ' + err.message)
  } finally {
    addLoading.value = false
  }
}

function startEdit(cat) {
  editId.value   = cat.id
  editName.value = cat.name
}

async function saveEdit(cat) {
  if (!editName.value.trim()) return
  const { error } = await supabase.from('categories')
    .update({ name: editName.value.trim() })
    .eq('id', cat.id)
  if (error) {
    toast.error('Güncellenemedi: ' + error.message)
  } else {
    cat.name   = editName.value.trim()
    editId.value = null
    toast.success('Kategori güncellendi.')
  }
}

function cancelEdit() { editId.value = null }

async function confirmDelete(cat) {
  // Count associated products
  const { count } = await supabase.from('products')
    .select('*', { count: 'exact', head: true })
    .eq('category_id', cat.id)

  deleteTarget.value = cat
  deleteWarning.value = count > 0
    ? `Bu kategoride ${count} ürün bulunmaktadır. Kategoriyi silmeden önce ürünleri başka bir kategoriye taşıyın veya silin.`
    : `'${cat.name}' kategorisini silmek istediğinizden emin misiniz?`

  if (count > 0) {
    toast.error(`Önce ${count} ürünü başka kategoriye taşıyın ya da silin.`)
    return
  }
  showConfirm.value = true
}

async function handleDelete() {
  if (!deleteTarget.value) return
  showConfirm.value = false
  const { error } = await supabase.from('categories').delete().eq('id', deleteTarget.value.id)
  if (error) {
    toast.error('Silinemedi: ' + error.message)
  } else {
    toast.success('Kategori silindi.')
    fetchCategories()
  }
  deleteTarget.value = null
}

async function moveUp(idx) {
  if (idx === 0) return
  const a = categories.value[idx]
  const b = categories.value[idx - 1]
  await Promise.all([
    supabase.from('categories').update({ display_order: b.display_order }).eq('id', a.id),
    supabase.from('categories').update({ display_order: a.display_order }).eq('id', b.id),
  ])
  ;[categories.value[idx], categories.value[idx - 1]] = [b, a]
}

async function moveDown(idx) {
  if (idx === categories.value.length - 1) return
  const a = categories.value[idx]
  const b = categories.value[idx + 1]
  await Promise.all([
    supabase.from('categories').update({ display_order: b.display_order }).eq('id', a.id),
    supabase.from('categories').update({ display_order: a.display_order }).eq('id', b.id),
  ])
  ;[categories.value[idx], categories.value[idx + 1]] = [b, a]
}

onMounted(fetchCategories)
</script>

<template>
  <div class="p-6 max-w-3xl mx-auto space-y-6">
    <div>
      <div class="flex items-center gap-3 mb-1">
        <Tags class="w-5 h-5 text-terracotta-600" />
        <h1 class="font-display text-2xl font-bold text-brown-800">Kategoriler</h1>
      </div>
      <p class="text-brown-500 text-sm">Menü kategorilerini yönetin</p>
    </div>

    <!-- Add new -->
    <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-4">
      <h2 class="text-sm font-semibold text-brown-700 mb-3">Yeni Kategori Ekle</h2>
      <div class="flex gap-2">
        <input
          v-model="newName"
          type="text"
          placeholder="Kategori adı…"
          @keydown.enter="handleAdd"
          id="new-category-input"
          class="flex-1 px-4 py-2.5 rounded-xl border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors"
        />
        <button
          id="add-category-btn"
          @click="handleAdd"
          :disabled="addLoading || !newName.trim()"
          class="flex items-center gap-2 px-4 py-2.5 bg-terracotta-600 text-white rounded-xl text-sm font-semibold hover:bg-terracotta-500 disabled:opacity-60 transition-colors"
        >
          <Plus class="w-4 h-4" /> Ekle
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="space-y-2">
      <div v-for="i in 4" :key="i" class="skeleton h-14 rounded-xl" />
    </div>

    <!-- Empty -->
    <div v-else-if="categories.length === 0" class="text-center py-12 text-brown-400">
      <Tags class="w-10 h-10 mx-auto mb-2 opacity-30" />
      <p>Henüz kategori eklenmedi.</p>
    </div>

    <!-- Category list -->
    <div v-else class="bg-white rounded-2xl border border-brown-100 shadow-sm overflow-hidden">
      <div
        v-for="(cat, idx) in categories"
        :key="cat.id"
        class="flex items-center gap-3 px-4 py-3 hover:bg-cream-50 transition-colors"
        :class="idx < categories.length - 1 ? 'border-b border-brown-100' : ''"
      >
        <!-- Order buttons -->
        <div class="flex flex-col gap-0.5 shrink-0">
          <button
            @click="moveUp(idx)"
            :disabled="idx === 0"
            class="text-brown-300 hover:text-brown-600 disabled:opacity-20 transition-colors leading-none"
            aria-label="Yukarı taşı"
          >
            ▲
          </button>
          <button
            @click="moveDown(idx)"
            :disabled="idx === categories.length - 1"
            class="text-brown-300 hover:text-brown-600 disabled:opacity-20 transition-colors leading-none"
            aria-label="Aşağı taşı"
          >
            ▼
          </button>
        </div>

        <!-- Name (edit mode) -->
        <div class="flex-1 min-w-0">
          <input
            v-if="editId === cat.id"
            v-model="editName"
            type="text"
            :id="`edit-cat-${cat.id}`"
            @keydown.enter="saveEdit(cat)"
            @keydown.escape="cancelEdit"
            class="w-full px-3 py-1.5 rounded-lg border border-terracotta-300 text-brown-800 text-sm bg-cream-50 focus:outline-none"
            autofocus
          />
          <p v-else class="text-sm font-semibold text-brown-800">{{ cat.name }}</p>
        </div>

        <!-- Actions -->
        <div class="flex items-center gap-1 shrink-0">
          <template v-if="editId === cat.id">
            <button @click="saveEdit(cat)" class="p-2 rounded-lg text-olive-600 hover:bg-olive-100 transition-colors" aria-label="Kaydet">
              <Check class="w-4 h-4" />
            </button>
            <button @click="cancelEdit" class="p-2 rounded-lg text-brown-400 hover:bg-cream-100 transition-colors" aria-label="İptal">
              <X class="w-4 h-4" />
            </button>
          </template>
          <template v-else>
            <button
              :id="`edit-cat-btn-${cat.id}`"
              @click="startEdit(cat)"
              class="p-2 rounded-lg text-brown-400 hover:bg-cream-100 hover:text-brown-700 transition-colors"
              aria-label="Düzenle"
            >
              <Pencil class="w-4 h-4" />
            </button>
            <button
              :id="`delete-cat-${cat.id}`"
              @click="confirmDelete(cat)"
              class="p-2 rounded-lg text-brown-400 hover:bg-terracotta-100 hover:text-terracotta-600 transition-colors"
              aria-label="Sil"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </template>
        </div>
      </div>
    </div>
  </div>

  <ConfirmDialog
    v-if="showConfirm"
    title="Kategoriyi Sil"
    :message="deleteWarning"
    confirm-text="Evet, Sil"
    @confirm="handleDelete"
    @cancel="showConfirm = false; deleteTarget = null"
  />
</template>
