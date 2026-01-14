<script setup lang="ts">
  const { t } = useI18n({ useScope: "local" });
  const emit = defineEmits<{ close: [boolean] }>();
  const props = defineProps<{
    market: Market;
    isSell?: boolean;
  }>();
</script>

<template>
  <UModal :close="{ onClick: () => emit('close', false) }">
    <template #title>
      <div class="flex items-center justify-start space-x-2 pr-4">
        <UAvatar :src="market.image" size="2xl" class="rounded-sm" />
        <div class="text-sm font-medium">
          {{ market.title }}
        </div>
      </div>
    </template>
    <template #description> </template>
    <template #body>
      <MarketTradeForm :market="props.market" :is-sell="props.isSell" />
    </template>
  </UModal>
</template>

<i18n>
{
  "en": {
    "title": "Buy Condition Token Form",
    "description": "This strategy is executed using only buy orders."
  },
  "zh": {
    "title": "购买条件代币表单",
    "This strategy is executed using only buy orders.": "此策略仅会挂买单。",
  }
}
</i18n>
