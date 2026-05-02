<template>
  <div class="flex flex-col min-h-screen">
    <NuxtRouteAnnouncer />
    <SiteHeader />
    <main class="flex-1 animate-flicker">
      <NuxtPage />
    </main>
    <SiteFooter />
  </div>
</template>
