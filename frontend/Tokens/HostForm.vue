<script setup lang="ts">
  import airdropAbi from "~/config/abis/airdrop.json";

  const { t } = useI18n();
  let amount = $ref(999);
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
    const rz = await getList("buy-token:host");
    list = rz?.data || [];
    isChecking = false;
  });
  const { network } = $(walletStore());

  const features = [
    t("999 $PCT"),
    t("Create 10 own rooms"),
    t("Earn 50% of platform fees from your rooms"),
  ];
</script>

<template>
  <div class="fbc flex-col gap-6 py-10">
    <div class="mb-10 text-xl font-bold">999 $PCT + 10 Host(50% fee share)= 999 USDC</div>
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
        price="999 USDC"
        :features
        :button="{
          label: 'Check on Blockchain browser',
          to: useExplorerUrl(network, `/tx/${list[0].hash}`),
          target: '_blank',
          variant: 'outline',
          trailingIcon: 'i-lucide-arrow-right',
        }"
      >
      </UPricingPlan>
      <UButton to="https://t.me/+a0aXzuxiNns5YWJl" target="_blank">Join PP Hoster Telegram Group</UButton>
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
            reason: 'buy-token:host',
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
