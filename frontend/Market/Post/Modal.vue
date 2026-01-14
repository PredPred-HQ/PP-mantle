<script setup lang="ts">
  const emit = defineEmits<{ close: [boolean] }>();
  const { item } = $defineProps<{
    item: {
      title: string;
      image: string;
      id: string;
      commentsCount: number;
      tokenYesCount: number;
      tokenNoCount: number;
    };
  }>();
  const { t } = useI18n();
</script>

<template>
  <UDrawer :close="{ onClick: () => emit('close', false) }" :overlay="false" :modal="true" should-scale-background set-background-color-on-scale>
    <template #body>
      <MarketPostList :item="item" />
    </template>
  </UDrawer>
</template>
