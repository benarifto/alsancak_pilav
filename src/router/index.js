import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js'

const routes = [
  {
    path: '/',
    redirect: '/menu',
  },
  {
    path: '/menu',
    name: 'menu',
    component: () => import('@/views/MenuView.vue'),
    meta: { title: 'Menü' },
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: 'Yönetici Girişi' },
  },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'admin-dashboard',
        component: () => import('@/views/admin/DashboardView.vue'),
        meta: { title: 'Yönetim Paneli' },
      },
      {
        path: 'products',
        name: 'admin-products',
        component: () => import('@/views/admin/ProductsView.vue'),
        meta: { title: 'Ürünler' },
      },
      {
        path: 'categories',
        name: 'admin-categories',
        component: () => import('@/views/admin/CategoriesView.vue'),
        meta: { title: 'Kategoriler' },
      },
      {
        path: 'settings',
        name: 'admin-settings',
        component: () => import('@/views/admin/SettingsView.vue'),
        meta: { title: 'Restoran Ayarları' },
      },
      {
        path: 'qr',
        name: 'admin-qr',
        component: () => import('@/views/admin/QRView.vue'),
        meta: { title: 'QR Kod Yönetimi' },
      },
    ],
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/menu',
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) return { el: to.hash, behavior: 'smooth' }
    return { top: 0 }
  },
})

// Navigation guard
router.beforeEach(async (to) => {
  // Set page title
  document.title = to.meta.title ? `${to.meta.title} | Restoran` : 'Restoran'

  if (!to.meta.requiresAuth) return true

  const authStore = useAuthStore()

  // Wait for auth to initialize if needed
  if (authStore.loading) {
    await authStore.init()
  }

  if (!authStore.isAuthenticated) {
    return { name: 'login', query: { next: to.fullPath } }
  }

  return true
})

export default router
