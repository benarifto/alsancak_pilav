<script setup>
import { ref, computed } from 'vue'
import { Upload, X, Image as ImageIcon } from '@lucide/vue'
import { validateImageFile, resizeImage, generateStorageFilename } from '@/lib/imageHelpers.js'
import { supabase } from '@/lib/supabase.js'

const props = defineProps({
  bucket:      { type: String, required: true },
  prefix:      { type: String, default: 'uploads' },
  currentUrl:  { type: String, default: null },
})

const emit = defineEmits(['uploaded', 'error'])

const previewUrl   = ref(props.currentUrl || null)
const uploading    = ref(false)
const errorMessage = ref('')
const fileInput    = ref(null)
const isDragOver   = ref(false)

const hasPreview = computed(() => !!previewUrl.value)

function openFilePicker() {
  fileInput.value?.click()
}

function handleDragOver(e) {
  e.preventDefault()
  isDragOver.value = true
}

function handleDragLeave() {
  isDragOver.value = false
}

function handleDrop(e) {
  e.preventDefault()
  isDragOver.value = false
  const file = e.dataTransfer?.files?.[0]
  if (file) processFile(file)
}

function handleFileChange(e) {
  const file = e.target.files?.[0]
  if (file) processFile(file)
}

async function processFile(file) {
  errorMessage.value = ''
  const validationError = validateImageFile(file)
  if (validationError) {
    errorMessage.value = validationError
    return
  }

  // Show local preview immediately
  previewUrl.value = URL.createObjectURL(file)

  try {
    uploading.value = true

    // Resize & compress
    const blob     = await resizeImage(file)
    const ext      = blob.type === 'image/webp' ? 'webp' : 'jpeg'
    const filename = generateStorageFilename(props.prefix, ext)

    const { data, error } = await supabase.storage
      .from(props.bucket)
      .upload(filename, blob, { contentType: blob.type, upsert: false })

    if (error) throw error

    const { data: urlData } = supabase.storage
      .from(props.bucket)
      .getPublicUrl(data.path)

    emit('uploaded', urlData.publicUrl)
  } catch (err) {
    errorMessage.value = 'Resim yüklenirken bir hata oluştu: ' + (err.message || '')
    emit('error', err)
  } finally {
    uploading.value = false
  }
}

function clearImage() {
  previewUrl.value = null
  if (fileInput.value) fileInput.value.value = ''
  emit('uploaded', null)
}
</script>

<template>
  <div class="space-y-2">
    <!-- Drop Zone -->
    <div
      class="relative border-2 border-dashed rounded-xl transition-colors cursor-pointer overflow-hidden"
      :class="[
        isDragOver ? 'border-terracotta-500 bg-terracotta-100/50' : 'border-brown-200 hover:border-brown-300',
        hasPreview ? 'h-48' : 'h-36',
      ]"
      @click="openFilePicker"
      @dragover="handleDragOver"
      @dragleave="handleDragLeave"
      @drop="handleDrop"
      role="button"
      tabindex="0"
      @keydown.enter="openFilePicker"
      aria-label="Resim yükle"
    >
      <!-- Preview -->
      <img
        v-if="hasPreview"
        :src="previewUrl"
        alt="Önizleme"
        class="w-full h-full object-cover"
      />

      <!-- Overlay / placeholder -->
      <div
        class="absolute inset-0 flex flex-col items-center justify-center gap-2 transition-opacity"
        :class="hasPreview ? 'bg-brown-800/50 opacity-0 hover:opacity-100' : 'opacity-100'"
      >
        <div class="w-10 h-10 rounded-full bg-cream-100 flex items-center justify-center">
          <Upload v-if="!uploading" class="w-5 h-5 text-brown-500" />
          <div v-else class="w-5 h-5 border-2 border-brown-400 border-t-transparent rounded-full animate-spin" />
        </div>
        <span class="text-sm font-medium text-cream-50" v-if="hasPreview">
          {{ uploading ? 'Yükleniyor…' : 'Değiştir' }}
        </span>
        <div v-else class="text-center px-4">
          <p class="text-sm font-medium text-brown-600">
            {{ uploading ? 'Yükleniyor…' : 'Tıkla veya sürükle bırak' }}
          </p>
          <p class="text-xs text-brown-400 mt-1">JPG, PNG, WebP — Maks. 5 MB</p>
        </div>
      </div>
    </div>

    <!-- Clear button -->
    <button
      v-if="hasPreview && !uploading"
      @click.stop="clearImage"
      type="button"
      class="text-xs text-terracotta-600 hover:text-terracotta-500 flex items-center gap-1 transition-colors"
    >
      <X class="w-3 h-3" /> Resmi kaldır
    </button>

    <!-- Error -->
    <p v-if="errorMessage" class="text-xs text-terracotta-600">{{ errorMessage }}</p>

    <!-- Hidden input -->
    <input
      ref="fileInput"
      type="file"
      accept="image/jpeg,image/png,image/webp,image/gif"
      class="hidden"
      @change="handleFileChange"
    />
  </div>
</template>
