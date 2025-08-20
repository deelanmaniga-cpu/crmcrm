<template>
  <div>
    <header class="header">
      <h1>CRM Offers</h1>
      <div class="right">
        <button class="btn" @click="$router.push('/')">Поиск</button>
        <button class="btn" @click="$router.push('/admin')">Вход</button>
      </div>
    </header>
    <router-view />
  </div>
</template>

<script setup>
</script>
