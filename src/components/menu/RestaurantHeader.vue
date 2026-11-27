<script setup>
import { computed, ref } from 'vue'
import { Phone, MapPin, Clock, Image as ImageIcon } from '@lucide/vue'

const props = defineProps({
  restaurant: { type: Object, default: null },
})

const logoError = ref(false)

const hours = computed(() => {
  const oh = props.restaurant?.opening_hours
  if (!oh) return []
  return Object.entries(oh).map(([day, time]) => ({ day, time }))
})

const hasHours     = computed(() => hours.value.length > 0)
const hasContact   = computed(() => props.restaurant?.phone || props.restaurant?.address)
const showHours    = ref(false)
</script>

<template>
  <header class="bg-cream-50 border-b border-brown-100">
    <div class="max-w-3xl mx-auto px-4 pt-8 pb-6 text-center">
      <!-- Logo -->
      <div class="flex justify-center mb-4">
        <div class="w-20 h-20 rounded-2xl overflow-hidden bg-cream-200 flex items-center justify-center shadow-sm">
          <img
            v-if="restaurant?.logo_url && !logoError"
            :src="restaurant.logo_url"
            :alt="restaurant?.name || 'Logo'"
            class="w-full h-full object-cover"
            @error="logoError = true"
          />
          <ImageIcon v-else class="w-10 h-10 text-brown-300" />
        </div>
      </div>

      <!-- Name -->
      <h1 class="font-display text-3xl font-bold text-brown-800">
        {{ restaurant?.name || 'Restoran Adı' }}
      </h1>

      <!-- Description -->
      <p
        v-if="restaurant?.description"
        class="mt-2 text-brown-500 text-sm leading-relaxed max-w-md mx-auto"
      >
        {{ restaurant.description }}
      </p>

      <!-- Contact row -->
      <div
        v-if="hasContact || hasHours"
        class="mt-4 flex flex-wrap items-center justify-center gap-4 text-xs text-brown-500"
      >
        <a
          v-if="restaurant?.phone"
          :href="`tel:${restaurant.phone}`"
          class="flex items-center gap-1.5 hover:text-terracotta-600 transition-colors"
        >
          <Phone class="w-3.5 h-3.5" />
          {{ restaurant.phone }}
        </a>

        <span
          v-if="restaurant?.address"
          class="flex items-center gap-1.5"
        >
          <MapPin class="w-3.5 h-3.5" />
          {{ restaurant.address }}
        </span>

        <button
          v-if="hasHours"
          @click="showHours = !showHours"
          class="flex items-center gap-1.5 hover:text-terracotta-600 transition-colors"
        >
          <Clock class="w-3.5 h-3.5" />
          Çalışma Saatleri
        </button>
      </div>

      <!-- Opening hours dropdown -->
      <Transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div
          v-if="showHours && hasHours"
          class="mt-4 max-w-xs mx-auto bg-cream-100 rounded-xl p-4 text-left"
        >
          <dl class="space-y-1.5">
            <div
              v-for="item in hours"
              :key="item.day"
              class="flex justify-between text-xs"
            >
              <dt class="font-medium text-brown-700">{{ item.day }}</dt>
              <dd class="text-brown-500">{{ item.time }}</dd>
            </div>
          </dl>
        </div>
      </Transition>
    </div>
  </header>
</template>
