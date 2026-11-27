<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js'
import { useToastStore } from '@/stores/toast.js'
import { Eye, EyeOff, Lock } from '@lucide/vue'

const router    = useRouter()
const route     = useRoute()
const authStore = useAuthStore()
const toast     = useToastStore()

const email       = ref('')
const password    = ref('')
const showPw      = ref(false)
const loading     = ref(false)
const errorMsg    = ref('')
const showReset   = ref(false)
const resetEmail  = ref('')
const resetSent   = ref(false)
const resetLoading = ref(false)

async function handleLogin() {
  errorMsg.value = ''
  if (!email.value || !password.value) {
    errorMsg.value = 'E-posta ve şifre alanları zorunludur.'
    return
  }

  try {
    loading.value = true
    await authStore.login(email.value.trim(), password.value)
    const next = route.query.next || '/admin'
    router.push(next)
  } catch (err) {
    if (err.message?.includes('Invalid login')) {
      errorMsg.value = 'E-posta veya şifre hatalı.'
    } else if (err.message?.includes('Email not confirmed')) {
      errorMsg.value = 'Lütfen önce e-posta adresinizi onaylayın.'
    } else {
      errorMsg.value = 'Giriş yapılamadı: ' + (err.message || 'Bilinmeyen hata.')
    }
  } finally {
    loading.value = false
  }
}

async function handleReset() {
  if (!resetEmail.value) {
    errorMsg.value = 'Lütfen e-posta adresinizi girin.'
    return
  }
  try {
    resetLoading.value = true
    await authStore.sendPasswordReset(resetEmail.value.trim())
    resetSent.value = true
  } catch (err) {
    errorMsg.value = 'Şifre sıfırlama e-postası gönderilemedi.'
  } finally {
    resetLoading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-cream-50 flex items-center justify-center p-4">
    <div class="w-full max-w-sm">
      <!-- Logo area -->
      <div class="text-center mb-8">
        <div class="w-14 h-14 bg-brown-800 rounded-2xl flex items-center justify-center mx-auto mb-4">
          <Lock class="w-7 h-7 text-cream-100" />
        </div>
        <h1 class="font-display text-2xl font-bold text-brown-800">Yönetici Girişi</h1>
        <p class="text-brown-400 text-sm mt-1">Sadece yetkili kullanıcılar</p>
      </div>

      <!-- Login form -->
      <div v-if="!showReset" class="bg-white rounded-2xl shadow-sm border border-brown-100 p-6 space-y-4">
        <div>
          <label for="email" class="block text-sm font-medium text-brown-700 mb-1.5">E-posta</label>
          <input
            id="email"
            v-model="email"
            type="email"
            autocomplete="email"
            placeholder="ornek@email.com"
            @keydown.enter="handleLogin"
            class="w-full px-4 py-2.5 rounded-lg border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors placeholder:text-brown-300"
          />
        </div>

        <div>
          <label for="password" class="block text-sm font-medium text-brown-700 mb-1.5">Şifre</label>
          <div class="relative">
            <input
              id="password"
              v-model="password"
              :type="showPw ? 'text' : 'password'"
              autocomplete="current-password"
              placeholder="••••••••"
              @keydown.enter="handleLogin"
              class="w-full px-4 py-2.5 pr-11 rounded-lg border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors placeholder:text-brown-300"
            />
            <button
              type="button"
              @click="showPw = !showPw"
              class="absolute right-3 top-1/2 -translate-y-1/2 text-brown-400 hover:text-brown-600"
              :aria-label="showPw ? 'Şifreyi gizle' : 'Şifreyi göster'"
            >
              <EyeOff v-if="showPw" class="w-4 h-4" />
              <Eye v-else class="w-4 h-4" />
            </button>
          </div>
        </div>

        <!-- Error -->
        <p v-if="errorMsg" role="alert" class="text-xs text-terracotta-600 bg-terracotta-100 px-3 py-2 rounded-lg">
          {{ errorMsg }}
        </p>

        <button
          id="login-submit"
          @click="handleLogin"
          :disabled="loading"
          class="w-full py-3 bg-brown-800 text-cream-50 rounded-lg text-sm font-semibold hover:bg-brown-700 disabled:opacity-60 transition-colors"
        >
          <span v-if="loading" class="flex items-center justify-center gap-2">
            <span class="w-4 h-4 border-2 border-cream-100 border-t-transparent rounded-full animate-spin" />
            Giriş yapılıyor…
          </span>
          <span v-else>Giriş Yap</span>
        </button>

        <button
          type="button"
          @click="showReset = true; errorMsg = ''"
          class="w-full text-xs text-brown-400 hover:text-terracotta-600 transition-colors text-center pt-1"
        >
          Şifremi unuttum
        </button>
      </div>

      <!-- Password reset form -->
      <div v-else class="bg-white rounded-2xl shadow-sm border border-brown-100 p-6 space-y-4">
        <div v-if="!resetSent">
          <h2 class="font-semibold text-brown-800 mb-1">Şifre Sıfırla</h2>
          <p class="text-xs text-brown-500 mb-4">Kayıtlı e-posta adresinize sıfırlama bağlantısı göndereceğiz.</p>

          <label for="reset-email" class="block text-sm font-medium text-brown-700 mb-1.5">E-posta</label>
          <input
            id="reset-email"
            v-model="resetEmail"
            type="email"
            placeholder="ornek@email.com"
            class="w-full px-4 py-2.5 rounded-lg border border-brown-200 text-brown-800 text-sm bg-cream-50 focus:outline-none focus:border-terracotta-400 transition-colors placeholder:text-brown-300 mb-3"
          />

          <p v-if="errorMsg" role="alert" class="text-xs text-terracotta-600 mb-3">{{ errorMsg }}</p>

          <button
            id="reset-submit"
            @click="handleReset"
            :disabled="resetLoading"
            class="w-full py-3 bg-brown-800 text-cream-50 rounded-lg text-sm font-semibold hover:bg-brown-700 disabled:opacity-60 transition-colors"
          >
            {{ resetLoading ? 'Gönderiliyor…' : 'Sıfırlama Bağlantısı Gönder' }}
          </button>
          <button @click="showReset = false; errorMsg = ''" class="w-full mt-2 text-xs text-brown-400 hover:text-brown-600 transition-colors">
            ← Geri dön
          </button>
        </div>

        <div v-else class="text-center py-4">
          <p class="text-sm text-brown-700 font-medium">✓ E-posta gönderildi!</p>
          <p class="text-xs text-brown-500 mt-2">Gelen kutunuzu kontrol edin ve bağlantıya tıklayın.</p>
          <button @click="showReset = false; resetSent = false" class="mt-4 text-xs text-terracotta-600 hover:underline">
            Giriş sayfasına dön
          </button>
        </div>
      </div>

      <!-- Back to menu -->
      <div class="text-center mt-6">
        <RouterLink to="/menu" class="text-xs text-brown-400 hover:text-terracotta-600 transition-colors">
          ← Menüye dön
        </RouterLink>
      </div>
    </div>
  </div>
</template>
