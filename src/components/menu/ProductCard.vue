<script setup>
import { ref, computed } from 'vue'
import { Image as ImageIcon } from '@lucide/vue'
import { formatPrice } from '@/lib/formatters.js'

const props = defineProps({
  product: { type: Object, required: true },
})

const imgError = ref(false)

function onImgError() {
  imgError.value = true
}

const imgSrc = computed(() => {
  if (imgError.value || !props.product.image_url) return null
  // Request a smaller transform from Supabase if it's a Supabase Storage URL
  const url = props.product.image_url
  if (url.includes('supabase')) {
    return url + '?width=400&quality=80'
  }
  return url
})
</script>

<template>
  <article
    class="group flex gap-4 py-4 border-b border-brown-100 last:border-0 transition-colors hover:bg-cream-100/60 rounded-xl px-3 -mx-3"
  >
    <!-- Product image -->
    <div class="shrink-0 w-24 h-24 sm:w-28 sm:h-28 rounded-xl overflow-hidden bg-cream-200">
      <img
        v-if="imgSrc"
        :src="imgSrc"
        :alt="product.name"
        loading="lazy"
        decoding="async"
        class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
        @error="onImgError"
      />
      <div v-else class="w-full h-full flex items-center justify-center">
        <ImageIcon class="w-8 h-8 text-brown-200" />
      </div>
    </div>

    <!-- Content -->
    <div class="flex-1 min-w-0 flex flex-col justify-between">
      <div>
        <h3 class="font-display font-semibold text-brown-800 text-base leading-tight truncate">
          {{ product.name }}
        </h3>
        <p
          v-if="product.description"
          class="text-sm text-brown-500 mt-1 line-clamp-2 leading-relaxed"
        >
          {{ product.description }}
        </p>
      </div>
      <div class="mt-2">
        <span class="inline-block font-semibold text-terracotta-600 text-sm">
          {{ formatPrice(product.price) }}
        </span>
      </div>
    </div>
  </article>
</template>
