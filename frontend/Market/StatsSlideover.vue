<script setup lang="ts">
  import type { TabsItem } from "@nuxt/ui";

  const { market } = $(marketStore());
  const { item, tab } = $defineProps<{
    item: {
      title: string;
      image: string;
      id: string;
      commentsCount: number;
      tokenYesCount: number;
      tokenNoCount: number;
    };
    tab: string;
  }>();
  const emit = defineEmits<{ close: [boolean] }>();
  let active = $ref(tab);

  const items: TabsItem[] = [
    {
      label: "Holders",
      value: "Holders",
      slot: "holders",
    },
    {
      label: "Yes Tokens",
      value: "Yes Tokens",
      slot: "yesTokens",
    },
    {
      label: "No Tokens",
      value: "No Tokens",
      slot: "noTokens",
    },
  ];
</script>

<template>
  <USlideover
    :close="{ onClick: () => emit('close', false) }"
    :ui="{ content: 'max-w-4/5 lg:max-w-1/2' }"
  >
    <template #title>
      <div class="flex items-center justify-start space-x-2 pr-6">
        <UAvatar :src="item.image" size="2xl" class="rounded-sm" />
        <div class="text-sm font-medium">
          {{ item.title }}
        </div>
      </div>
    </template>
    <template #description></template>
    <template #body>
      <UTabs v-model="active" :items="items" variant="link" :ui="{ trigger: 'flex-1' }">
        <template #holders>
          <MarketHoldersList :digest="market.digest" />
        </template>
        <template #yesTokens>
          <MarketTradeLogsList
            :digest="market.digest"
            :nft-id="market.yesNftId"
          />
        </template>
        <template #noTokens>
          <MarketTradeLogsList
            :digest="market.digest"
            :nft-id="market.noNftId"
          />
        </template>
      </UTabs>
    </template>
  </USlideover>
</template>
