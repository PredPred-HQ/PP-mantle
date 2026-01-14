<script setup lang="ts">
  import airdropAbi from "~/config/abis/airdrop.json";

  const { t } = useI18n();
  let amount = $ref(25);
  let canPayPct = $ref(false);
  let canPay = $ref(false);
  const { doPay, isLoading, error, clearError } = $(web3PaymentStore());
  const disabled = $computed(() => !(canPay || isLoading));
</script>

<template>
  <div class="fbc flex-col gap-6 py-10">
    <div class="mb-10 text-xl font-bold">{{ amount }} $PCT = {{ amount }} USDC</div>
    <USlider v-model="amount" :min="10" :max="50" />
    <Web3Balance
      :title="t('Your $PCT Balance')"
      token="pct"
      :amount="0"
      spender-name="airdrop"
      $can-pay="canPayPct"
    />
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
          reason: 'buy-token:try',
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
  </div>
</template>
