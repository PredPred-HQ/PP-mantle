<template>
  <UModal
    :close="{ onClick: () => emit('close', false) }"
    :title="t('Share to X and Get Rewards!')"
  >
    <template #body>
      <div class="text-center">
        <div class="mb-4 text-4xl">📣</div>
        <p class="mb-6 text-gray-300">
          Let your followers know about PredP.red <br />
          and become part of our growing community!
        </p>

        <div class="space-y-4">
          <UButton @click="handleShare">
            <div class="flex items-center justify-center">
              <svg class="mr-2 h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
                ></path>
              </svg>
              Share to X
            </div>
          </UButton>
        </div>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
  const { t } = useI18n();
  const { shareToX, getUserCount, userCount } = $(supabaseStore());
  const { hideModal } = $(modalStore());

  const handleShare = async () => {
    await getUserCount();
    const shareText = `🚀 Join PredP.red waiting list now!\n\n📈 The first unlimited liquidity Prediction Market\n\n🎯 Get ready for the future of prediction markets!\n\n👥 I'm the ${userCount + 1}th user to join! \n\n @PredPred_HQ`;
    await shareToX(shareText);
    hideModal("marketTaskShareToX");
  };

  onMounted(async () => {
    await getUserCount();
  });
</script>
