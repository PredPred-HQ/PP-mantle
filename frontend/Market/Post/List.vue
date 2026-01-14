<script setup lang="ts">
  import { breakpointsTailwind } from "@vueuse/core";
  import { computed, ref, watch } from "vue";
  import type { Mail } from "~/types";

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
  const tabItems = [
    {
      label: "All",
      value: "all",
    },
    {
      label: "Unread",
      value: "unread",
    },
  ];
  const selectedTab = ref("all");

  const { data: mails } = await useFetch<Mail[]>("/api/mails", { default: () => [] });

  // Filter mails based on the selected tab
  const filteredMails = computed(() => {
    if (selectedTab.value === "unread") {
      return mails.value.filter((mail) => !!mail.unread);
    }

    return mails.value;
  });

  const selectedMail = ref<Mail | null>();

  const isMailPanelOpen = computed({
    get() {
      return !!selectedMail.value;
    },
    set(value: boolean) {
      if (!value) {
        selectedMail.value = null;
      }
    },
  });

  // Reset selected mail if it's not in the filtered mails
  watch(filteredMails, () => {
    if (!filteredMails.value.find((mail) => mail.id === selectedMail.value?.id)) {
      selectedMail.value = null;
    }
  });

  const breakpoints = useBreakpoints(breakpointsTailwind);
  const isMobile = breakpoints.smaller("lg");
</script>

<template>
  <UDashboardPanel :id="`market-post-list-${item.id}`" :default-size="40">
    <div class="flex items-center justify-start space-x-2 pr-4">
      <UAvatar :src="item.image" size="2xl" class="rounded-sm" />
      <div class="text-sm font-medium">
        {{ item.title }}
      </div>
    </div>
    <div class="fbc px-4">
      <UTabs v-model="selectedTab" :items="tabItems" :content="false" size="xs" />
      <UButton variant="ghost" icon="material-symbols:add-circle"></UButton>
    </div>
    <InboxList v-model="selectedMail" :mails="filteredMails" />
  </UDashboardPanel>

  <InboxMail v-if="selectedMail" :mail="selectedMail" @close="selectedMail = null" />
  <div v-else class="hidden flex-1 items-center justify-center lg:flex">
    <UIcon name="i-lucide-inbox" class="text-dimmed size-32" />
  </div>

  <ClientOnly>
    <USlideover v-if="isMobile" v-model:open="isMailPanelOpen">
      <template #content>
        <InboxMail v-if="selectedMail" :mail="selectedMail" @close="selectedMail = null" />
      </template>
    </USlideover>
  </ClientOnly>
</template>
