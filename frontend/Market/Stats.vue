<script setup lang="ts">
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
  const { showModal } = $(modalStore());
</script>

<template>
  <div class="divide-y divide-white/5 text-sm hover:cursor-pointer">
    <div
      v-if="false"
      class="hover:bg-primary-500 flex justify-between rounded-md p-2 pt-3 text-gray-400 hover:text-white"
      @click="showModal('marketPost', { item })"
    >
      <dt class="fbc space-x-2 pl-2">
        <UAvatarGroup size="xs">
          <UAvatar
            src="https://github.com/benjamincanac.png"
            alt="Benjamin Canac"
            :chip="{ inset: true, color: 'success' }"
          />

          <UAvatar
            src="https://github.com/romhml.png"
            alt="Romain Hamel"
            :chip="{ inset: true, color: 'warning' }"
          />

          <UAvatar
            src="https://github.com/noook.png"
            alt="Neil Richter"
            :chip="{ inset: true, color: 'error' }"
          />
        </UAvatarGroup>
        <div>1000+</div>
      </dt>
      <dd>
        <UButton color="neutral" variant="outline" trailing-icon="material-symbols:android-chat">{{
          t("Join")
        }}</UButton>
      </dd>
    </div>
    <div
      class="hover:bg-primary-500 flex justify-between rounded-md p-2 pt-3 text-gray-400 hover:text-white"
      @click="showModal('marketStatsSlideover', { item, tab: 'Holders' })"
    >
      <dt class="pl-2">{{ t("Holders") }}</dt>
      <dd class="fbc">
        <!-- <div>{{ item.holdersCount || 0 }}</div> -->
        <UIcon name="material-symbols:chevron-right" class="ml-4 size-6" />
      </dd>
    </div>
    <div
      class="hover:bg-primary-500 flex justify-between rounded-md p-2 pt-3 text-gray-400 hover:text-white"
      @click="showModal('marketStatsSlideover', { item, tab: 'Yes Tokens' })"
    >
      <dt class="pl-2">{{ t("Yes Tokens") }}</dt>
      <dd class="fbc">
        <!-- <div>{{ item.tokenYesCount || 0 }}</div> -->
        <UIcon name="material-symbols:chevron-right" class="ml-4 size-6" />
      </dd>
    </div>
    <div
      class="hover:bg-primary-500 flex justify-between rounded-md p-2 pt-3 text-gray-400 hover:text-white"
      @click="showModal('marketStatsSlideover', { item, tab: 'No Tokens' })"
    >
      <dt class="pl-2">{{ t("No Tokens") }}</dt>
      <dd class="fbc">
        <!-- <div>{{ item.tokenNoCount || 0 }}</div> -->
        <UIcon name="material-symbols:chevron-right" class="ml-4 size-6" />
      </dd>
    </div>
  </div>
</template>

<i18n>{
  "en": {
    "Comments": "Comments",
    "Yes Tokens": "Yes Tokens",
    "No Tokens": "No Tokens",
    "Holders": "Holders",
  },
  "zh": {
    "Comments": "评论",
    "Yes Tokens": "Yes 代币",
    "No Tokens": "No 代币",
    "Holders": "持有者",
  }
}
</i18n>
