<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import RestaurantHeader from '@/components/menu/RestaurantHeader.vue'
import CategoryNav from '@/components/menu/CategoryNav.vue'
import ProductCard from '@/components/menu/ProductCard.vue'
import { UtensilsCrossed, AlertCircle } from '@lucide/vue'

// ── State ──────────────────────────────────────────────────────────────────
const restaurant       = ref(null)
const categories       = ref([])
const products         = ref([])
const loading          = ref(true)
const error            = ref(null)
const activeCategory   = ref(null)
const isSupabaseReady  = computed(() => !!import.meta.env.VITE_SUPABASE_URL?.includes('.supabase.co'))

// ── Filtered data ───────────────────────────────────────────────────────────
const visibleCategories = computed(() => {
  return categories.value.filter(cat =>
    products.value.some(p => p.category_id === cat.id)
  )
})

function productsForCategory(catId) {
  return products.value
    .filter(p => p.category_id === catId)
    .sort((a, b) => a.display_order - b.display_order)
}

// ── Data fetching ───────────────────────────────────────────────────────────
async function fetchMenu() {
  if (!isSupabaseReady.value) {
    // Show demo state when Supabase isn't configured yet
    loading.value = false
    return
  }

  try {
    loading.value = true
    error.value   = null

    const [{ data: restData, error: restErr }, { data: catData, error: catErr }, { data: prodData, error: prodErr }] =
      await Promise.all([
        supabase.from('restaurants').select('*').limit(1).single(),
        supabase.from('categories').select('*').order('display_order'),
        supabase.from('products').select('*').eq('is_available', true).order('display_order'),
      ])

    if (restErr) throw restErr
    if (catErr)  throw catErr
    if (prodErr) throw prodErr

    restaurant.value = restData
    categories.value = catData || []
    products.value   = prodData || []

    if (visibleCategories.value.length > 0) {
      activeCategory.value = visibleCategories.value[0].id
    }
  } catch (err) {
    console.error('Menü yüklenemedi:', err)
    error.value = 'Menü yüklenirken bir hata oluştu. Lütfen sayfayı yenileyin.'
  } finally {
    loading.value = false
  }
}

// ── Scroll-spy ──────────────────────────────────────────────────────────────
function setupScrollSpy() {
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          const id = entry.target.id.replace('category-', '')
          activeCategory.value = id
        }
      }
    },
    { rootMargin: '-64px 0px -60% 0px', threshold: 0 }
  )

  setTimeout(() => {
    visibleCategories.value.forEach(cat => {
      const el = document.getElementById(`category-${cat.id}`)
      if (el) observer.observe(el)
    })
  }, 100)

  return observer
}

let observer = null

onMounted(async () => {
  await fetchMenu()
  if (visibleCategories.value.length > 0) {
    observer = setupScrollSpy()
  }
})

onUnmounted(() => {
  observer?.disconnect()
})
</script>

<template>
  <div class="min-h-screen bg-cream-50">
    <!-- Loading skeletons -->
    <div v-if="loading">
      <!-- Header skeleton -->
      <div class="bg-cream-50 border-b border-brown-100 px-4 pt-8 pb-6">
        <div class="max-w-3xl mx-auto text-center space-y-3">
          <div class="skeleton w-20 h-20 rounded-2xl mx-auto" />
          <div class="skeleton h-8 w-48 mx-auto" />
          <div class="skeleton h-4 w-72 mx-auto" />
        </div>
      </div>
      <!-- Nav skeleton -->
      <div class="border-b border-brown-100 px-4 py-3 flex gap-2">
        <div v-for="i in 4" :key="i" class="skeleton h-8 w-24 rounded-full" />
      </div>
      <!-- Products skeleton -->
      <div class="max-w-3xl mx-auto px-4 py-6 space-y-6">
        <div v-for="g in 3" :key="g">
          <div class="skeleton h-6 w-32 mb-4" />
          <div v-for="i in 3" :key="i" class="flex gap-4 py-4 border-b border-brown-100">
            <div class="skeleton w-24 h-24 rounded-xl shrink-0" />
            <div class="flex-1 space-y-2">
              <div class="skeleton h-5 w-3/4" />
              <div class="skeleton h-4 w-full" />
              <div class="skeleton h-4 w-1/2" />
              <div class="skeleton h-5 w-20 mt-2" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Setup notice (Supabase not configured) -->
    <div v-else-if="!isSupabaseReady" class="flex flex-col items-center justify-center min-h-screen p-8 text-center">
      <div class="w-16 h-16 rounded-2xl bg-terracotta-100 flex items-center justify-center mb-4">
        <AlertCircle class="w-8 h-8 text-terracotta-600" />
      </div>
      <h2 class="font-display text-2xl font-semibold text-brown-800 mb-2">Kurulum Gerekiyor</h2>
      <p class="text-brown-500 max-w-sm leading-relaxed">
        Menüyü görüntülemek için önce <strong>.env</strong> dosyasını oluşturun ve
        Supabase bilgilerinizi girin. Detaylar için
        <strong>SETUP_GUIDE_TR.md</strong> dosyasına bakın.
      </p>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="flex flex-col items-center justify-center min-h-screen p-8 text-center">
      <div class="w-16 h-16 rounded-2xl bg-terracotta-100 flex items-center justify-center mb-4">
        <AlertCircle class="w-8 h-8 text-terracotta-600" />
      </div>
      <h2 class="font-display text-2xl font-semibold text-brown-800 mb-2">Bir Hata Oluştu</h2>
      <p class="text-brown-500 max-w-sm">{{ error }}</p>
      <button
        @click="fetchMenu"
        class="mt-6 px-6 py-2.5 bg-brown-800 text-cream-50 rounded-lg text-sm font-medium hover:bg-brown-700 transition-colors"
      >
        Tekrar Dene
      </button>
    </div>

    <!-- Empty menu -->
    <div
      v-else-if="visibleCategories.length === 0"
      class="flex flex-col items-center justify-center min-h-screen p-8 text-center"
    >
      <div class="w-16 h-16 rounded-2xl bg-cream-200 flex items-center justify-center mb-4">
        <UtensilsCrossed class="w-8 h-8 text-brown-300" />
      </div>
      <h2 class="font-display text-2xl font-semibold text-brown-800 mb-2">Menü Henüz Hazır Değil</h2>
      <p class="text-brown-500">Yakında hizmetinizdeyiz.</p>
    </div>

    <!-- Menu content -->
    <template v-else>
      <RestaurantHeader :restaurant="restaurant" />

      <CategoryNav
        :categories="visibleCategories"
        :active-category="activeCategory"
        @select="id => activeCategory = id"
      />

      <main class="max-w-3xl mx-auto px-4 py-6 space-y-10">
        <section
          v-for="cat in visibleCategories"
          :key="cat.id"
          :id="`category-${cat.id}`"
        >
          <h2 class="font-display text-2xl font-bold text-brown-800 mb-4 pb-2 border-b-2 border-terracotta-100">
            {{ cat.name }}
          </h2>
          <div>
            <ProductCard
              v-for="product in productsForCategory(cat.id)"
              :key="product.id"
              :product="product"
            />
          </div>
        </section>
      </main>

      <!-- Footer -->
      <footer class="text-center py-8 text-xs text-brown-300 border-t border-brown-100 mt-6">
        {{ restaurant?.name }} &copy; {{ new Date().getFullYear() }}
      </footer>
    </template>
  </div>
</template>
