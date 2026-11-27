<script setup>
import { ref, onMounted, computed } from 'vue'
import QRCode from 'qrcode'
import { supabase } from '@/lib/supabase.js'
import { QrCode, Download, Printer, ExternalLink, Copy, Check } from '@lucide/vue'

// ── State ──────────────────────────────────────────────────────────────────
const restaurantName = ref('Restoran Adı')
const qrCanvas       = ref(null)
const qrSvgString    = ref('')
const copied         = ref(false)
const loading        = ref(true)

const publicMenuUrl = computed(() => {
  const configured = import.meta.env.VITE_PUBLIC_MENU_URL
  if (configured && !configured.includes('your-site')) return configured
  return window.location.origin + '/menu'
})

// ── Init ───────────────────────────────────────────────────────────────────
onMounted(async () => {
  const { data } = await supabase.from('restaurants').select('name').limit(1).single()
  if (data?.name) restaurantName.value = data.name
  loading.value = false
  // Generate QR after DOM ready
  await generateQR()
})

async function generateQR() {
  const url = publicMenuUrl.value

  // Canvas version (for PNG download and display)
  if (qrCanvas.value) {
    await QRCode.toCanvas(qrCanvas.value, url, {
      width: 300,
      margin: 3,
      color: { dark: '#3b2314', light: '#fdfaf5' },
      errorCorrectionLevel: 'H',
    })
  }

  // SVG string for SVG download
  qrSvgString.value = await QRCode.toString(url, {
    type: 'svg',
    margin: 3,
    color: { dark: '#3b2314', light: '#fdfaf5' },
    errorCorrectionLevel: 'H',
    width: 300,
  })
}

// ── Downloads ──────────────────────────────────────────────────────────────
function downloadPNG() {
  if (!qrCanvas.value) return
  const link = document.createElement('a')
  link.download = 'qr-menu.png'
  link.href = qrCanvas.value.toDataURL('image/png')
  link.click()
}

function downloadSVG() {
  if (!qrSvgString.value) return
  const blob = new Blob([qrSvgString.value], { type: 'image/svg+xml' })
  const link = document.createElement('a')
  link.download = 'qr-menu.svg'
  link.href = URL.createObjectURL(blob)
  link.click()
  URL.revokeObjectURL(link.href)
}

function printPage() {
  window.print()
}

async function copyUrl() {
  await navigator.clipboard.writeText(publicMenuUrl.value)
  copied.value = true
  setTimeout(() => copied.value = false, 2000)
}
</script>

<template>
  <div class="p-6 max-w-3xl mx-auto space-y-8">
    <!-- Header -->
    <div>
      <div class="flex items-center gap-3 mb-1">
        <QrCode class="w-5 h-5 text-terracotta-600" />
        <h1 class="font-display text-2xl font-bold text-brown-800">QR Kod Yönetimi</h1>
      </div>
      <p class="text-brown-500 text-sm">Müşterileriniz için menü QR kodunu oluşturun ve indirin</p>
    </div>

    <!-- URL display -->
    <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-5">
      <label class="block text-sm font-semibold text-brown-700 mb-2">Menü URL'si</label>
      <div class="flex items-center gap-2">
        <div class="flex-1 flex items-center gap-2 px-4 py-2.5 rounded-xl bg-cream-100 border border-brown-200 min-w-0">
          <span class="text-sm text-brown-600 truncate">{{ publicMenuUrl }}</span>
        </div>
        <button
          @click="copyUrl"
          id="copy-url-btn"
          class="p-2.5 rounded-xl border border-brown-200 bg-white hover:bg-cream-100 transition-colors"
          :aria-label="copied ? 'Kopyalandı' : 'URL\'yi kopyala'"
        >
          <Check v-if="copied" class="w-4 h-4 text-olive-600" />
          <Copy v-else class="w-4 h-4 text-brown-500" />
        </button>
        <a
          :href="publicMenuUrl"
          target="_blank"
          class="p-2.5 rounded-xl border border-brown-200 bg-white hover:bg-cream-100 transition-colors"
          aria-label="Menüyü yeni sekmede aç"
        >
          <ExternalLink class="w-4 h-4 text-brown-500" />
        </a>
      </div>
      <p class="mt-2 text-xs text-brown-400">
        Bu URL değişmez. Ürün ve fiyat güncellemelerinde QR kodu yeniden basmanız gerekmez.
      </p>
    </div>

    <!-- QR Code display -->
    <div class="bg-white rounded-2xl border border-brown-100 shadow-sm p-6 no-print">
      <h2 class="text-sm font-semibold text-brown-700 mb-5 text-center">QR Kod Önizlemesi</h2>
      <div class="flex justify-center">
        <div class="p-4 bg-cream-50 rounded-2xl border border-brown-100 inline-block">
          <canvas ref="qrCanvas" id="qr-canvas" class="block" />
        </div>
      </div>

      <!-- Download buttons -->
      <div class="flex flex-wrap gap-3 justify-center mt-6">
        <button
          id="download-png"
          @click="downloadPNG"
          class="flex items-center gap-2 px-5 py-2.5 bg-brown-800 text-cream-50 rounded-xl text-sm font-semibold hover:bg-brown-700 transition-colors"
        >
          <Download class="w-4 h-4" /> PNG İndir
        </button>
        <button
          id="download-svg"
          @click="downloadSVG"
          class="flex items-center gap-2 px-5 py-2.5 border border-brown-200 text-brown-700 rounded-xl text-sm font-semibold hover:bg-cream-100 transition-colors"
        >
          <Download class="w-4 h-4" /> SVG İndir
        </button>
        <button
          id="print-qr"
          @click="printPage"
          class="flex items-center gap-2 px-5 py-2.5 border border-brown-200 text-brown-700 rounded-xl text-sm font-semibold hover:bg-cream-100 transition-colors"
        >
          <Printer class="w-4 h-4" /> Yazdır (A4)
        </button>
      </div>
    </div>

    <!-- Instructions -->
    <div class="bg-cream-100 rounded-2xl p-5 text-sm text-brown-600 space-y-2">
      <p class="font-semibold text-brown-800 mb-1">Nasıl kullanılır?</p>
      <ul class="list-disc pl-5 space-y-1 text-brown-500">
        <li>QR kodu PNG veya SVG olarak indirin.</li>
        <li>A4 kağıda yazdırıp masaların üzerine koyun.</li>
        <li>Müşteriler telefonlarını kodu üzerinde tuttuğunda menü açılır.</li>
        <li>Menü güncellemelerinde QR kodu değişmez, yeniden basmanız gerekmez.</li>
      </ul>
    </div>
  </div>

  <!-- ============================================================ -->
  <!-- Print layout (only visible when printing) -->
  <!-- ============================================================ -->
  <div class="hidden print:block">
    <div class="print-page">
      <!-- 4 copies of the QR on an A4 page -->
      <div class="print-grid">
        <div v-for="i in 4" :key="i" class="print-card">
          <p class="print-restaurant">{{ restaurantName }}</p>
          <div class="print-qr" v-html="qrSvgString" />
          <p class="print-caption">Menümüzü görüntülemek için okutun.</p>
          <p class="print-url">{{ publicMenuUrl }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Print styles — only applied when window.print() is called */
@media print {
  .print-page {
    width: 210mm;
    min-height: 297mm;
    padding: 15mm;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .print-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15mm;
    width: 100%;
  }

  .print-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 10mm;
    border: 1px solid #e4ccaa;
    border-radius: 8mm;
    page-break-inside: avoid;
  }

  .print-restaurant {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 16pt;
    font-weight: 700;
    color: #3b2314;
    margin-bottom: 5mm;
    text-align: center;
  }

  .print-qr {
    width: 55mm;
    height: 55mm;
  }

  .print-qr :deep(svg) {
    width: 100%;
    height: 100%;
  }

  .print-caption {
    font-family: 'Inter', sans-serif;
    font-size: 10pt;
    color: #4f3122;
    margin-top: 4mm;
    text-align: center;
    font-weight: 500;
  }

  .print-url {
    font-family: 'Inter', sans-serif;
    font-size: 7pt;
    color: #a67c52;
    margin-top: 2mm;
    text-align: center;
  }
}
</style>
