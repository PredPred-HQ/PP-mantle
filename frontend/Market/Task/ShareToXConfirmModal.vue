<script setup lang="ts">
  const { t } = useI18n();
  const { twitterInfo, hasTwitterLogin } = $(supabaseStore());
  const { hideModal, showModal } = $(modalStore());
  let { currentStep } = $(shareToXStore());

  let retweetLink = $ref("https://x.com/PredPred_HQ/status/2007093064066846728");
  let isLoading = $ref(false);
  const disabled = $computed(
    () =>
      !hasTwitterLogin ||
      !retweetLink ||
      !retweetLink.startsWith(`https://x.com/${twitterInfo.user_name}`) ||
      isLoading
  );

  const { network } = $(walletStore());

  const handleConfirm = async () => {
    if (isLoading) {
      return;
    }
    isLoading = true;
    const rz = await doFetch("/api/airdrop/saveRetweetLink", {
      method: "POST",
      body: {
        retweetLink,
        network,
        reason: "airdrop:retweet",
      },
    });
    isLoading = false;
    if (rz.error) {
      showModal("alert", { title: "Error", message: rz.message });
      if (rz.statusMessage === "AlreadySubmitted") {
        currentStep = "claimReward";
        return;
      }
    }
    currentStep = "claimReward";
    hideModal("marketTaskShareToXConfirm");
  };
</script>

<template>
  <UModal
    :close="{ onClick: () => emit('close', false) }"
    :title="t('Submit posted x url and Get rewards!')"
  >
    <template #body>
      <div class="text-center">
        <p class="mb-6 text-gray-300">
          Submit x url you have shared <br />
          and then get the rewards!
        </p>
        <UInput v-model="retweetLink" class="mb-4 w-full" />

        <div class="space-y-4">
          <UButton
            :loading="isLoading"
            :disabled="disabled"
            :color="disabled ? 'neutral' : 'primary'"
            :variant="disabled ? 'outline' : 'solid'"
            @click="handleConfirm"
          >
            <div class="flex items-center justify-center">
              <svg class="mr-2 h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
                ></path>
              </svg>
              {{ t("Confirm") }}
            </div>
          </UButton>
        </div>
      </div>
    </template>
  </UModal>
</template>
