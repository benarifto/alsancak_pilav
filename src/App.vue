<script setup>
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { useToastStore } from '@/stores/toast.js'
import ToastContainer from '@/components/ui/ToastContainer.vue'

const authStore = useAuthStore()
const toastStore = useToastStore()

onMounted(() => {
  authStore.init()
})
</script>

<template>
  <RouterView />
  <ToastContainer :toasts="toastStore.toasts" @remove="toastStore.remove" />
</template>
