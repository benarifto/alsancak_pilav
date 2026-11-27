<script setup>
defineProps({
  categories:      { type: Array, default: () => [] },
  activeCategory:  { type: String, default: null },
})

const emit = defineEmits(['select'])

function scrollTo(id) {
  emit('select', id)
  const el = document.getElementById(`category-${id}`)
  if (el) {
    const offset = 72 // height of the sticky nav
    const top = el.getBoundingClientRect().top + window.scrollY - offset
    window.scrollTo({ top, behavior: 'smooth' })
  }
}
</script>

<template>
  <nav
    class="sticky top-0 z-30 bg-cream-50/90 backdrop-blur-sm border-b border-brown-100 overflow-x-auto scrollbar-hide"
    aria-label="Kategori navigasyonu"
  >
    <div class="flex gap-1 px-4 py-2 max-w-3xl mx-auto">
      <button
        v-for="cat in categories"
        :key="cat.id"
        :id="`nav-${cat.id}`"
        @click="scrollTo(cat.id)"
        class="shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 whitespace-nowrap"
        :class="activeCategory === cat.id
          ? 'bg-brown-800 text-cream-50'
          : 'text-brown-600 hover:bg-brown-100'"
        :aria-current="activeCategory === cat.id ? 'true' : undefined"
      >
        {{ cat.name }}
      </button>
    </div>
  </nav>
</template>
