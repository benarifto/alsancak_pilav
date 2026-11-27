/**
 * Resize and compress an image file using the Canvas API.
 * Returns a Blob (WebP preferred, JPEG fallback).
 *
 * @param {File} file - The original file from an <input type="file">
 * @param {object} opts
 * @param {number} opts.maxWidth  - Max width in px (default 1200)
 * @param {number} opts.maxHeight - Max height in px (default 1200)
 * @param {number} opts.quality   - 0–1 quality (default 0.82)
 * @returns {Promise<Blob>}
 */
export function resizeImage(file, { maxWidth = 1200, maxHeight = 1200, quality = 0.82 } = {}) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    const url = URL.createObjectURL(file)

    img.onload = () => {
      URL.revokeObjectURL(url)

      let { width, height } = img
      if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height)
        width  = Math.round(width * ratio)
        height = Math.round(height * ratio)
      }

      const canvas = document.createElement('canvas')
      canvas.width  = width
      canvas.height = height
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, width, height)

      // Try WebP first, fall back to JPEG
      const type = 'image/webp'
      canvas.toBlob(
        (blob) => {
          if (blob) return resolve(blob)
          // Fallback
          canvas.toBlob((jpegBlob) => {
            if (jpegBlob) return resolve(jpegBlob)
            reject(new Error('Resim sıkıştırılamadı.'))
          }, 'image/jpeg', quality)
        },
        type,
        quality
      )
    }

    img.onerror = () => {
      URL.revokeObjectURL(url)
      reject(new Error('Resim yüklenemedi.'))
    }

    img.src = url
  })
}

/**
 * Generate a unique filename for Supabase Storage.
 * e.g. products/1700000000000-abc123.webp
 */
export function generateStorageFilename(prefix = 'uploads', ext = 'webp') {
  const ts    = Date.now()
  const rand  = Math.random().toString(36).slice(2, 8)
  return `${prefix}/${ts}-${rand}.${ext}`
}

/** Max allowed image size in bytes (5 MB) */
export const MAX_IMAGE_SIZE = 5 * 1024 * 1024

/** Allowed MIME types */
export const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']

/**
 * Validate an image file. Returns an error string or null.
 */
export function validateImageFile(file) {
  if (!file) return 'Lütfen bir dosya seçin.'
  if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
    return 'Yalnızca JPG, PNG, WebP veya GIF dosyası yükleyebilirsiniz.'
  }
  if (file.size > MAX_IMAGE_SIZE) {
    return 'Dosya boyutu 5 MB\'dan küçük olmalıdır.'
  }
  return null
}
