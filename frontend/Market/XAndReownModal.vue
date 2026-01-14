<script setup lang="ts">
  import type { StepperItem } from "@nuxt/ui";

  const { t } = useI18n({ useScope: "local" });
  const emit = defineEmits<{ close: [boolean] }>();
  const items = ref<StepperItem[]>([
    {
      title: "X Auth",
      icon: "line-md:twitter-x",
      slot: "xAuth" as const,
    },
    {
      title: "Wallet Connection",
      icon: "logos:metamask-icon",
      slot: "walletConnect" as const,
    },
  ]);

  const { isLogined } = $(supabaseStore());
  let active = $ref(0);
  watchOnce(
    () => isLogined,
    (newVal) => {
      active = newVal ? 1 : 0;
    }
  );
</script>

<template>
  <UModal
    :close="{ onClick: () => emit('close', false) }"
    :title="t('X Auth and connect wallet first')"
  >
    <template #body>
      <UStepper v-model="active" :items="items" class="w-full">
        <template #xAuth="{ item }">
          <div class="flex items-center justify-center p-10">
            <AuthXBtn />
          </div>
        </template>
        <template #walletConnect="{ item }">
          <div class="flex items-center justify-center p-10">
            <appkit-button />
          </div>
        </template>
      </UStepper>
    </template>
  </UModal>
</template>

<i18n>
{
  "en": {
    "X Auth and connect wallet first": "X Auth and connect wallet first",
  },
  "zh": {
    "X Auth and connect wallet first": "请先 X 登录并连接钱包",
  }
}
</i18n>
