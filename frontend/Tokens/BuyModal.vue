<script setup lang="ts">
  const { t } = useI18n({ useScope: "local" });
  const emit = defineEmits<{ close: [boolean] }>();
  const props = defineProps<{
    item: { title: string; description: string };
  }>();
  const { clearError } = $(web3PaymentStore());
  const doClose = () => {
    clearError();
    emit("close", false);
  };
</script>

<template>
  <UModal
    :title="t('Buy $PCT Tokens')"
    :description="item.description"
    @update:open="doClose"
  >
    <template #body>
      <TokensTryForm v-if="item.title === 'Try'" />
      <TokensLoveForm v-if="item.title === 'Love'" />
      <TokensHostForm v-if="item.title === 'Host'" />
    </template>
  </UModal>
</template>

<i18n>
{
  "en": {
  },
  "zh": {
  }
}
</i18n>
