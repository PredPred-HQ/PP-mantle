<script setup lang="ts">
  import airdropAbi from "~/config/abis/airdrop.json";

  const { t } = useI18n();
  let amount = $ref(99);
  let canPayPct = $ref(false);
  let canPay = $ref(false);
  const { doPay, isLoading, error, clearError, getList } = $(web3PaymentStore());
  const disabled = $computed(() => !(canPay || isLoading));
  const { twitterInfo } = $(supabaseStore());

  let list = $ref({});
  let isChecking = $ref(false);
  const hasBuyToken = $computed(() => list.length > 0);
  onMounted(async () => {
    isChecking = true;
    const rz = await getList("buy-token:love");
    list = rz?.data || [];
    isChecking = false;
  });
  const { network } = $(walletStore());

  const features = [t("200 $PCT"), t("One X account"), t("One purchase opportunity only")];
</script>

<template>
  <div class="fbc flex-col gap-6 py-10">
    <div class="mb-10 text-xl font-bold">200 $PCT = 99 USDC</div>
    <div class="fbc w-full px-4">
      <div>Your X Account</div>
      <UUser
        :name="twitterInfo.name"
        :description="twitterInfo.email"
        :avatar="{
          src: twitterInfo.avatar,
          icon: 'i-lucide-image',
        }"
      />
    </div>
    <Web3Balance
      :title="t('Your $PCT Balance')"
      token="pct"
      :amount="0"
      spender-name="airdrop"
      $can-pay="canPayPct"
    />

    <template v-if="isChecking">
      <UProgress animation="swing" class="w-full" />
    </template>
    <template v-else-if="hasBuyToken">
      <UPricingPlan
        class="w-full"
        title="You have bought!"
        description="Package Love"
        price="200 USDC"
        discount="99 USDC"
        :features
        :button="{
          label: 'Check on Blockchain browser',
          to: useExplorerUrl(network, `/tx/${list[0].hash}`),
          target: '_blank',
          variant: 'ghost',
          trailingIcon: 'i-lucide-arrow-right',
        }"
      >
      </UPricingPlan>
      <UButton to="https://t.me/+csjQEdBIyV9jMTZl" target="_blank">Join PP Lover Telegram Group</UButton>
    </template>
    <template v-else>
      <Web3Balance
        :title="t('Your USDC Balance')"
        token="usdc"
        :amount="amount"
        spender-name="airdrop"
        $can-pay="canPay"
        class="mb-10"
      />
      <AlertError v-if="error" :description="error" @close="clearError" />
      <UButton
        :disabled="disabled"
        :loading="isLoading"
        @click="
          doPay({
            reason: 'buy-token:love',
            userSigKey: 'UserBuySig',
            operatorSigKey: 'OperatorBuySig',
            amount: amount.toString(),
            contractName: 'airdrop',
            abi: airdropAbi,
            abiKey: 'airdrop',
            functionName: 'buyToken',
            verifyEventName: 'TokenSold',
          })
        "
        >Pay {{ amount }} USDC</UButton
      >
    </template>
  </div>
</template>
