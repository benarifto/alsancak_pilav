<script setup>
import { TransitionGroup } from 'vue'
import { CheckCircle, XCircle, Info, X } from '@lucide/vue'

defineProps({
  toasts: { type: Array, default: () => [] },
})
const emit = defineEmits(['remove'])
</script>

<template>
  <div
    aria-live="polite"
    class="fixed bottom-5 right-5 z-50 flex flex-col gap-3 max-w-sm w-full pointer-events-none"
  >
    <TransitionGroup
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="translate-y-4 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-for="toast in toasts"
        :key="toast.id"
        class="pointer-events-auto flex items-start gap-3 rounded-xl px-4 py-3 shadow-lg text-sm font-medium"
        :class="{
          'bg-olive-600 text-white': toast.type === 'success',
          'bg-terracotta-600 text-white': toast.type === 'error',
          'bg-brown-700 text-cream-50': toast.type === 'info',
        }"
      >
        <CheckCircle v-if="toast.type === 'success'" class="w-5 h-5 shrink-0 mt-0.5" />
        <XCircle v-else-if="toast.type === 'error'" class="w-5 h-5 shrink-0 mt-0.5" />
        <Info v-else class="w-5 h-5 shrink-0 mt-0.5" />
        <span class="flex-1">{{ toast.message }}</span>
        <button
          @click="emit('remove', toast.id)"
          class="shrink-0 opacity-70 hover:opacity-100 transition-opacity"
          aria-label="Kapat"
        >
          <X class="w-4 h-4" />
        </button>
      </div>
    </TransitionGroup>
  </div>
</template>
