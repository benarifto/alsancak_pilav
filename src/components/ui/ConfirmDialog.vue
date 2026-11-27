<script setup>
import { X, AlertTriangle } from '@lucide/vue'

const props = defineProps({
  title:       { type: String, default: 'Emin misiniz?' },
  message:     { type: String, default: 'Bu işlem geri alınamaz.' },
  confirmText: { type: String, default: 'Evet, Sil' },
  cancelText:  { type: String, default: 'İptal' },
  danger:      { type: Boolean, default: true },
})

const emit = defineEmits(['confirm', 'cancel'])
</script>

<template>
  <!-- Backdrop -->
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      :aria-label="title"
    >
      <!-- Overlay -->
      <div
        class="absolute inset-0 bg-brown-800/60 backdrop-blur-sm"
        @click="emit('cancel')"
      />

      <!-- Dialog -->
      <div class="relative bg-cream-50 rounded-2xl shadow-2xl max-w-sm w-full p-6 z-10">
        <!-- Icon -->
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 rounded-full flex items-center justify-center"
               :class="danger ? 'bg-terracotta-100' : 'bg-olive-100'">
            <AlertTriangle class="w-5 h-5"
                           :class="danger ? 'text-terracotta-600' : 'text-olive-600'" />
          </div>
          <h3 class="font-display text-lg font-semibold text-brown-800">{{ title }}</h3>
        </div>

        <p class="text-brown-600 text-sm mb-6 leading-relaxed">{{ message }}</p>

        <div class="flex gap-3 justify-end">
          <button
            id="confirm-dialog-cancel"
            @click="emit('cancel')"
            class="px-4 py-2 rounded-lg text-sm font-medium text-brown-600 border border-brown-200 hover:bg-cream-100 transition-colors"
          >
            {{ cancelText }}
          </button>
          <button
            id="confirm-dialog-confirm"
            @click="emit('confirm')"
            class="px-4 py-2 rounded-lg text-sm font-medium text-white transition-colors"
            :class="danger
              ? 'bg-terracotta-600 hover:bg-terracotta-500'
              : 'bg-olive-600 hover:bg-olive-500'"
          >
            {{ confirmText }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
