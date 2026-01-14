<script setup lang="ts">
  import type { AccordionItem } from "@nuxt/ui";

  const { item } = $defineProps<{
    item: {
      title: string;
      description: string;
      image: string;
      date: string;
      priceYes: number;
      priceNo: number;
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

  const items = ref<AccordionItem[]>([
    {
      label: "Share to X, get 10 $PCT Airdrop",
      icon: "line-md:twitter-x",
      content: "shareX",
    },
    // {
    //   label: "Invite friends, get 10 $PCT * 10 Airdrop",
    //   icon: "streamline-ultimate:multiple-users-1",
    //   content: "Choose a primary and a neutral color from your Tailwind CSS theme.",
    // },
  ]);
  const active = ref('0')
</script>

<template>
  <UPageCard spotlight spotlight-color="primary">
    <UAccordion v-model="active" :items="items">
      <template #content="{ item }">
        <p v-if="item.content === 'shareX'" class="text-primary pb-3.5 text-sm">
          <MarketTaskShareX />
        </p>

        <p v-else class="text-primary pb-3.5 text-sm">
          {{ item.content }}
        </p>
      </template>
    </UAccordion>
    <MarketTaskLogs :item="item" />
  </UPageCard>
</template>

<i18n>{
  "en": {

  },
  "zh": {
  }
}
</i18n>
