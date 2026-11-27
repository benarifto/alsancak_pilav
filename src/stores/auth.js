import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase.js'

export const useAuthStore = defineStore('auth', () => {
  const session = ref(null)
  const loading = ref(true)

  const isAuthenticated = computed(() => !!session.value)
  const userEmail = computed(() => session.value?.user?.email ?? '')

  /**
   * Initialize — call once at app startup.
   * Restores existing session and listens for auth state changes.
   */
  async function init() {
    loading.value = true
    const { data } = await supabase.auth.getSession()
    session.value = data.session

    supabase.auth.onAuthStateChange((_event, newSession) => {
      session.value = newSession
    })
    loading.value = false
  }

  async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    session.value = data.session
    return data
  }

  async function logout() {
    await supabase.auth.signOut()
    session.value = null
  }

  async function sendPasswordReset(email) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/admin`,
    })
    if (error) throw error
  }

  return { session, loading, isAuthenticated, userEmail, init, login, logout, sendPasswordReset }
})
