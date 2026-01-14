<script setup lang="ts">
  import { useAppKitAccount } from "@reown/appkit/vue";
  import { sub } from "date-fns";
  import type { Period, Range } from "~/types";

  const { item } = $defineProps<{
    item: {
      title: string;
      description: string;
      image: string;
      date: string;
      priceYes: number;
      priceNo: number;
      poolTotalAmount: number;
      tokenYesCount: number;
      tokenNoCount: number;
      holdersCount: number;
      authors: {
        to: string;
        target: string;
        avatar: {
          src: string;
        };
      }[];
    };
  }>();
  const { t } = useI18n();
  let isOpen = $ref(false);
  const percent = computed(() => {
    return item.tokenYesCount + item.tokenNoCount > 0
      ? (item.tokenYesCount / (item.tokenYesCount + item.tokenNoCount)) * 100
      : 0;
  });

  const range = shallowRef<Range>({
    start: sub(new Date(), { days: 14 }),
    end: new Date(),
  });
  const period = ref<Period>("hourly");
  const { showModal } = $(modalStore());
  const { isLogined } = $(supabaseStore());
  const accountData = $(useAppKitAccount());
  const accountAddress = $computed(() => accountData.address);
  const openTradeModal = (opts) => {
    if (isLogined && accountAddress) {
      showModal("marketTrade", opts);
      return;
    }
    showModal("marketXAndReownModal");
  };
</script>

<template>
  <UPageCard
    spotlight
    spotlight-color="primary"
    :ui="{ header: 'w-full space-y-2 py-0', leading: 'w-full', footer: 'w-full' }"
  >
    <template #header>
      <div class="mb-2 flex items-center justify-start space-x-2">
        <UAvatar :src="item.image" size="2xl" class="rounded-sm" />
        <div class="text-sm font-medium">
          {{ item.title }}
        </div>
      </div>
      <UCollapsible v-model:open="isOpen" :ui="{ root: 'py-2' }">
        <div v-show="!isOpen" class="group text-xs">
          <div>
            {{ item.description.slice(0, 100) }}{{ item.description.length > 100 ? "..." : "" }}
          </div>
          <div class="flex items-center justify-end">
            <UButton variant="ghost" size="xs">
              {{ t("Show More") }}
              <UIcon name="i-lucide-chevron-down" class="ml-2 size-4" />
            </UButton>
          </div>
        </div>
        <template #content>
          <div class="text-muted-foreground text-xs">
            {{ item.description }}
          </div>
          <div class="flex items-center justify-end">
            <UButton variant="ghost" size="xs" @click="isOpen = false">
              {{ t("Show Less") }}
              <UIcon name="i-lucide-chevron-down" class="ml-2 size-4 rotate-180" />
            </UButton>
          </div>
        </template>
      </UCollapsible>

      <div class="mx-auto flex w-full flex-col gap-2">
        <div class="flex justify-between text-sm">
          <span> {{ t("Yes Token", item.tokenYesCount) }}</span>
          <span> {{ t("No Token", item.tokenNoCount) }}</span>
        </div>
        <UiProgress
          class="bg-error/90 h-2 [--primary:var(--color-success)]"
          :model-value="percent"
        />
      </div>
    </template>
    <template #leading>
      <MarketChart :period="period" :range="range" class="w-full" :total="item.poolTotalAmount" />
    </template>
    <template #footer>
      <div class="fbc mt-4 mb-8 space-x-6">
        <UButton
          block
          size="xl"
          color="success"
          class="text-white"
          @click="openTradeModal({ market: item })"
        >
          {{ t("Buy") }}
        </UButton>
        <UButton
          block
          size="xl"
          color="error"
          class="text-white"
          @click="openTradeModal({ market: item, isSell: true })"
        >
          {{ t("Sell") }}
        </UButton>
      </div>

      <MarketStats :item="item" />
    </template>
  </UPageCard>
</template>

<i18n>{
  "en": {
    "Show More": "Show More",
    "Show Less": "Show Less",
    "Buy Yes": "Buy Yes {price}",
    "Buy No": "Buy No {price}",
    "Yes Token": "{count} Yes Tokens",
    "No Token": "{count} No Tokens",
  },
  "zh": {
    "Show More": "显示更多",
    "Show Less": "显示更少",
    "Buy Yes": "购买是 {price}",
    "Buy No": "购买否 {price}",
    "Yes Token": "{count} 个是令牌",
    "No Token": "{count} 个否令牌",
  }
}
</i18n>
