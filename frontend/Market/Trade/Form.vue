<script setup lang="ts">
  import pctAbi from "~/config/abis/pct.json";
  import ppaAbi from "~/config/abis/ppa.json";
  import { formatEther, maxUint256 } from "viem";
  import type { TabsItem } from "@nuxt/ui";

  const { network, walletAddress, doWriteContract } = $(walletStore());
  let { getMarket, market, waitForTransactionReceipt } = $(marketStore());
  const { t } = useI18n();
  const { isSell } = $defineProps<{
    isSell?: boolean;
  }>();

  let active = $ref(isSell ? "sell" : "buy");
  const items: TabsItem[] = $computed(() => {
    return [
      {
        label: t("Buy"),
        value: "buy",
        slot: "buy",
      },
      {
        label: t("Sell"),
        value: "sell",
        slot: "sell",
      },
    ];
  });
  const color = $computed(() => (active === "buy" ? "success" : "error"));
  const priceYes = $computed(() => Number(formatEther(market.priceYes)).toFixed(2));
  const priceNo = $computed(() => Number(formatEther(market.priceNo)).toFixed(2));
  const buyItems = $computed(() => [
    {
      label: `Pay ${priceYes} $PCT to buy 1 Yes`,
      value: "yes",
    },
    {
      label: `Pay ${priceNo} $PCT to buy 1 No`,
      value: "no",
    },
  ]);
  let buyItem = $ref("yes");
  const price = $computed(() => (buyItem === "yes" ? priceYes : priceNo));

  const priceYesSell = $computed(() =>
    Number(
      formatEther(market.priceYes) * (1 - (2 * Number(market.platformFeeBps)) / 10000)
    ).toFixed(2)
  );
  const priceNoSell = $computed(() =>
    Number(formatEther(market.priceNo) * (1 - (2 * Number(market.platformFeeBps)) / 10000)).toFixed(
      2
    )
  );

  const sellItems = $computed(() => [
    {
      label: `Sell 1 yes to get ${priceYesSell} $PCT`,
      value: "yes",
    },
    {
      label: `Sell 1 no to get ${priceNoSell} $PCT`,
      value: "no",
    },
  ]);
  let isNftBalanceLoading = $ref(false);
  const sellNftName = $ref("yes");
  let nftBalance = $ref(0);
  let pctBalance = $ref(0n);
  let isPctBalanceLoading = $ref(false);
  const updatePctBalance = async () => {
    if (!walletAddress) {
      return;
    }
    isPctBalanceLoading = true;
    pctBalance = await readContract(network, "pct", pctAbi, "balanceOf", [walletAddress]);
    isPctBalanceLoading = false;
  };
  let isAllowanceLoading = $ref(false);
  let allowance = $ref(0n);
  const checkAllowance = async () => {
    if (!walletAddress) {
      return;
    }
    isAllowanceLoading = true;
    allowance = await readContract(network, "pct", pctAbi, "allowance", [
      walletAddress,
      getChainConfig(network, "ppa"),
    ]);
    isAllowanceLoading = false;
  };

  const priceRaw = $computed(() => (buyItem === "yes" ? market.priceYes : market.priceNo));
  const pctNotEnough = $computed(() => pctBalance < priceRaw);
  const allowanceNotEnough = $computed(() => allowance < priceRaw);
  const doApproveAllowance = async () => {
    isAllowanceLoading = true;
    const { hash, eventDataMap } = await doWriteContract(
      getChainConfig(network, "pct"),
      pctAbi,
      "approve",
      [getChainConfig(network, "ppa"), maxUint256],
      ["Approval"]
    );
    console.log({hash, eventDataMap})
    await checkAllowance();
    isAllowanceLoading = false;
  };

  const toast = useToast();

  let isBuyLoading = $ref(false);
  const canBuy = $computed(() => !isBuyLoading && !pctNotEnough && !allowanceNotEnough);
  const buyNftId = $computed(() => (buyItem === "yes" ? market.yesNftId : market.noNftId));
  const doBuy = async () => {
    isBuyLoading = true;
    try {
      const { hash, eventDataMap } = await doWriteContract(
        getChainConfig(network, "ppa"),
        ppaAbi,
        "buy",
        [market.digest, buyNftId],
        ["Buy", "UpdateMarket"]
      );
      await doFetch("/api/trade/logs", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: {
          hash,
          tradeArgs: eventDataMap.Buy,
          marketArgs: eventDataMap.UpdateMarket.marketData,
        },
      });

      await getMarket(market.digest, 1);
      toast.add({
        title: "Success",
        description: `You have successfully purchased ${buyItem === "yes" ? "1 Yes" : "1 No"}.`,
        color: "success",
      });
    } catch (e: any) {
      console.log("xxx", e);
      toast.add({
        title: "Error",
        description: e.shortMessage || "Transaction rejected.",
        color: "error",
      });
    } finally {
      isBuyLoading = false;
    }
  };
  const actionsPctBalance = [
    {
      label: "Get $PCT",
      variant: "outline",
      to: "/tokens",
      target: "_blank",
    },
  ];
  const actionsApproveAllowance = $computed(() => {
    return [
      {
        label: "Do Approve",
        variant: "outline",
        loading: isAllowanceLoading,
        onClick: doApproveAllowance,
      },
    ];
  });

  let isSellLoading = $ref(false);
  const canSell = $computed(() => !isSellLoading && nftBalance > 0);
  const sellNftId = $computed(() => (sellNftName === "yes" ? market.yesNftId : market.noNftId));

  const loadNftBalance = async () => {
    isNftBalanceLoading = true;
    nftBalance = await readContract(network, "ppa", ppaAbi, "balanceOf", [
      walletAddress,
      sellNftId,
    ]);
    isNftBalanceLoading = false;
  };

  const doSell = async () => {
    isSellLoading = true;
    try {
      const { hash, eventDataMap } = await doWriteContract(
        getChainConfig(network, "ppa"),
        ppaAbi,
        "sell",
        [market.digest, sellNftId],
        ["Sell", "UpdateMarket"]
      );
      const res = await doFetch("/api/trade/logs", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: {
          hash,
          tradeArgs: eventDataMap["Sell"],
          marketArgs: eventDataMap["UpdateMarket"].marketData,
        },
      });

      await getMarket(market.digest, 1);
      await loadNftBalance();

      toast.add({
        title: "Success",
        description: `You have successfully sold ${sellNftName === "yes" ? "1 Yes" : "1 No"}.`,
        color: "success",
      });
    } catch (e: any) {
      toast.add({
        title: "Error",
        description: e.shortMessage || "Transaction rejected.",
        color: "error",
      });
    } finally {
      isSellLoading = false;
    }
  };

  watch(() => sellNftName, loadNftBalance);
  watchEffect(async () => {
    await updatePctBalance();
    await checkAllowance();
    await loadNftBalance();
  });
</script>

<template>
  <UTabs v-model="active" :items="items" class="w-full" :color="color">
    <template #buy="{ item }">
      <div class="flex flex-col items-center justify-center space-y-6 px-4 py-8 pt-8">
        <URadioGroup
          v-model="buyItem"
          size="lg"
          color="primary"
          variant="table"
          default-value="pro"
          :items="buyItems"
          class="w-full"
        />

        <div class="fbc w-full px-4">
          <div>{{ t("$PCT Balance") }}</div>
          <div class="fbc space-x-2">
            <div v-if="isPctBalanceLoading">Loading...</div>
            <div v-else>{{ formatNumber(formatEther(pctBalance)) }}</div>
            <UButton
              :loading="isPctBalanceLoading"
              icon="material-symbols:sync"
              size="md"
              color="primary"
              variant="soft"
              @click="updatePctBalance()"
            />
          </div>
        </div>
        <UBanner
          v-if="pctNotEnough"
          color="error"
          title="$PCT Balance is not enough."
          :actions="actionsPctBalance"
        />
        <UBanner
          v-if="allowanceNotEnough"
          color="error"
          title="$PCT Allowance is not enough."
          :actions="actionsApproveAllowance"
        />
        <div class="mx-auto w-1/2">
          <UButton
            size="lg"
            color="primary"
            block
            :disabled="!canBuy"
            :loading="isBuyLoading"
            @click="doBuy"
            >{{ t("Pay", { price }) }}</UButton
          >
        </div>
      </div>
    </template>
    <template #sell="{ item }">
      <div class="flex flex-col items-center justify-center space-y-6 px-4 py-8 pt-8">
        <URadioGroup
          v-model="sellNftName"
          size="lg"
          color="error"
          variant="table"
          default-value="pro"
          :items="sellItems"
          class="w-full"
        />
        <div class="fbc w-full px-4">
          <div>{{ t("Your {sellNftName} NFT Balance", { sellNftName }) }}</div>
          <div class="fbc space-x-2">
            <div>{{ nftBalance }}</div>
            <UButton
              icon="material-symbols:sync"
              size="md"
              color="error"
              variant="soft"
              :loading="isNftBalanceLoading"
              @click="loadNftBalance"
            />
          </div>
        </div>
        <div class="mx-auto w-1/2">
          <UButton
            size="lg"
            color="error"
            block
            :loading="isSellLoading"
            :disabled="!canSell"
            @click="doSell"
            >{{ t("Sell 1 {sellNftName}", { sellNftName }) }}</UButton
          >
        </div>
      </div>
    </template>
  </UTabs>
</template>

<i18n>{
  "en": {
    "Buy Yes": "Buy Yes",
    "Buy No": "Buy No",
    "Pay": "Pay {price} $PCT",
    "Your {sellNftName} NFT Balance": "Your {sellNftName} NFT Balance",
    "Sell 1 {sellNftName}": "Sell 1 {sellNftName}",
  },
  "zh": {
    "Buy Yes": "购买 Yes",
    "Buy No": "购买 No",
    "Pay": "支付 {price} $PCT",
  },
}
</i18n>
