<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js'
import { supabase } from '@/lib/supabase.js'
import {
  LayoutDashboard, Package, Tags, Settings, QrCode,
  LogOut, Menu, X, ExternalLink, ChefHat
} from '@lucide/vue'

const router    = useRouter()
const authStore = useAuthStore()

const sidebarOpen    = ref(false)
const restaurantName = ref('Restoran Adı')

const navLinks = [
  { to: '/admin',            name: 'admin-dashboard',   label: 'Genel Bakış',    icon: LayoutDashboard },
  { to: '/admin/products',   name: 'admin-products',    label: 'Ürünler',         icon: Package },
  { to: '/admin/categories', name: 'admin-categories',  label: 'Kategoriler',     icon: Tags },
  { to: '/admin/settings',   name: 'admin-settings',    label: 'Ayarlar',         icon: Settings },
  { to: '/admin/qr',         name: 'admin-qr',          label: 'QR Kod',          icon: QrCode },
]

onMounted(async () => {
  const { data } = await supabase.from('restaurants').select('name').limit(1).single()
  if (data?.name) restaurantName.value = data.name
})

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}
</script>

<template>
  <div class="flex h-screen bg-cream-100 overflow-hidden">
    <!-- Sidebar (desktop) -->
    <aside
      class="hidden lg:flex flex-col w-60 bg-brown-800 text-cream-100 shrink-0"
    >
      <!-- Brand -->
      <div class="flex items-center gap-3 px-5 py-5 border-b border-brown-700">
        <div class="w-9 h-9 bg-terracotta-600 rounded-xl flex items-center justify-center shrink-0">
          <ChefHat class="w-5 h-5 text-white" />
        </div>
        <div class="min-w-0">
          <p class="text-xs text-brown-400 font-medium">Yönetim Paneli</p>
          <p class="text-sm font-semibold text-cream-100 truncate">{{ restaurantName }}</p>
        </div>
      </div>

      <!-- Nav -->
      <nav class="flex-1 py-4 px-3 space-y-1">
        <RouterLink
          v-for="link in navLinks"
          :key="link.to"
          :to="link.to"
          :id="`nav-${link.name}`"
          exact-active-class="bg-brown-700 text-cream-50"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-brown-300 hover:bg-brown-700/60 hover:text-cream-100 transition-colors"
        >
          <component :is="link.icon" class="w-4 h-4 shrink-0" />
          {{ link.label }}
        </RouterLink>
      </nav>

      <!-- Footer actions -->
      <div class="p-3 border-t border-brown-700 space-y-1">
        <a
          href="/menu"
          target="_blank"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-brown-300 hover:bg-brown-700/60 hover:text-cream-100 transition-colors"
        >
          <ExternalLink class="w-4 h-4 shrink-0" />
          Menüyü Görüntüle
        </a>
        <button
          id="sidebar-logout"
          @click="handleLogout"
          class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-brown-300 hover:bg-brown-700/60 hover:text-cream-100 transition-colors"
        >
          <LogOut class="w-4 h-4 shrink-0" />
          Çıkış Yap
        </button>
      </div>
    </aside>

    <!-- Mobile sidebar overlay -->
    <Transition
      enter-active-class="transition duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-150"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="sidebarOpen"
        class="lg:hidden fixed inset-0 z-40 bg-brown-900/60"
        @click="sidebarOpen = false"
      />
    </Transition>

    <Transition
      enter-active-class="transition duration-200"
      enter-from-class="-translate-x-full"
      enter-to-class="translate-x-0"
      leave-active-class="transition duration-150"
      leave-from-class="translate-x-0"
      leave-to-class="-translate-x-full"
    >
      <aside
        v-if="sidebarOpen"
        class="lg:hidden fixed inset-y-0 left-0 z-50 w-64 bg-brown-800 text-cream-100 flex flex-col"
      >
        <div class="flex items-center justify-between px-5 py-4 border-b border-brown-700">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-terracotta-600 rounded-xl flex items-center justify-center">
              <ChefHat class="w-4 h-4 text-white" />
            </div>
            <span class="text-sm font-semibold truncate max-w-32">{{ restaurantName }}</span>
          </div>
          <button @click="sidebarOpen = false" class="text-brown-400 hover:text-cream-100">
            <X class="w-5 h-5" />
          </button>
        </div>

        <nav class="flex-1 py-4 px-3 space-y-1">
          <RouterLink
            v-for="link in navLinks"
            :key="link.to"
            :to="link.to"
            exact-active-class="bg-brown-700 text-cream-50"
            class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-brown-300 hover:bg-brown-700/60 hover:text-cream-100 transition-colors"
            @click="sidebarOpen = false"
          >
            <component :is="link.icon" class="w-4 h-4 shrink-0" />
            {{ link.label }}
          </RouterLink>
        </nav>

        <div class="p-3 border-t border-brown-700">
          <button
            @click="handleLogout"
            class="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-brown-300 hover:bg-brown-700/60 hover:text-cream-100 transition-colors"
          >
            <LogOut class="w-4 h-4 shrink-0" />
            Çıkış Yap
          </button>
        </div>
      </aside>
    </Transition>

    <!-- Main content -->
    <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
      <!-- Mobile top bar -->
      <header class="lg:hidden flex items-center gap-3 px-4 py-3 bg-brown-800 text-cream-100 shrink-0">
        <button
          @click="sidebarOpen = true"
          class="p-1.5 rounded-lg hover:bg-brown-700 transition-colors"
          aria-label="Menüyü aç"
        >
          <Menu class="w-5 h-5" />
        </button>
        <div class="flex items-center gap-2 flex-1 min-w-0">
          <ChefHat class="w-4 h-4 text-terracotta-400 shrink-0" />
          <span class="text-sm font-semibold truncate">{{ restaurantName }}</span>
        </div>
        <a href="/menu" target="_blank" class="p-1.5 rounded-lg hover:bg-brown-700 transition-colors">
          <ExternalLink class="w-4 h-4 text-brown-400" />
        </a>
      </header>

      <!-- Page content -->
      <main class="flex-1 overflow-y-auto">
        <RouterView />
      </main>
    </div>
  </div>
</template>
