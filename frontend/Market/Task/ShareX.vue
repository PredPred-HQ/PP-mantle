<script lang="ts" setup>
  let { currentStep, getRetweetFromServer, retweet, doClaimReward, isClaimRewardLoading } =
    $(shareToXStore());
  const { showModal } = $(modalStore());
  const { hasTwitterLogin } = $(supabaseStore());
  const showShareModal = () => {
    currentStep = "submitRetweet";
    showModal("marketTaskShareToX");
  };

  const submitRetweet = () => {
    showModal("marketTaskShareToXConfirm");
  };
  onMounted(getRetweetFromServer);
</script>

<template>
  <div class="py-4">
    <AuthXBtn v-if="!hasTwitterLogin" />
    <template v-else>
      <div
        v-if="retweet?.status !== 'successed'"
        class="flex flex-col items-center justify-center gap-4 py-4 sm:flex-row"
      >
        <UButton
          :color="currentStep === 'shareToX' ? 'primary' : 'neutral'"
          :variant="currentStep === 'shareToX' ? 'solid' : 'outline'"
          @click="showShareModal"
          >1. Share to X</UButton
        >
        <UButton
          :color="currentStep === 'submitRetweet' ? 'primary' : 'neutral'"
          :variant="currentStep === 'submitRetweet' ? 'solid' : 'outline'"
          @click="submitRetweet"
          >2. Submit Retweet</UButton
        >
        <UButton
          :loading="isClaimRewardLoading"
          :disabled="isClaimRewardLoading"
          :color="currentStep === 'claimReward' ? 'primary' : 'neutral'"
          :variant="currentStep === 'claimReward' ? 'solid' : 'outline'"
          @click="doClaimReward('airdrop:retweet')"
          >{{ isClaimRewardLoading ? "Claiming..." : "3. Claim Reward" }}</UButton
        >
      </div>
      <UButton
        v-if="retweet?.retweetLink"
        :to="retweet?.retweetLink"
        target="_blank"
        variant="outline"
        block
        class="mt-4 max-w-full"
        trailing-icon="i-heroicons-arrow-top-right-on-square-20-solid"
      >
        Your Retweet Link
      </UButton>
      <UButton
        v-if="retweet?.hash"
        :to="useExplorerUrl(retweet?.network, `/tx/${retweet?.hash}`)"
        target="_blank"
        variant="outline"
        block
        class="mt-4 max-w-full"
        trailing-icon="i-heroicons-arrow-top-right-on-square-20-solid"
      >
        Your Reward Claimed Hash
      </UButton>
    </template>
  </div>
</template>

<i18n>{
  "en": {
  },
  "zh": {
  }
}
</i18n>
