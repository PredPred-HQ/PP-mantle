<script setup lang="ts">
  const props = defineProps<{
    digest: string;
    nftId: bigint;
  }>();

  const tradeLogs = ref<any[]>([]);
  const isLoading = ref(false);
  const {network} = $(walletStore())
  const fetchTradeLogs = async () => {
    isLoading.value = true;
    try {
      const response = await $fetch("/api/trade/logs", {
        query: {
          digest: props.digest,
          nft_id: props.nftId.toString(),
        },
      });
      tradeLogs.value = response.data || [];
    } catch (error) {
      console.error("Failed to fetch trade logs:", error);
      tradeLogs.value = [];
    } finally {
      isLoading.value = false;
    }
  };

  watch(() => [props.digest, props.tokenType], fetchTradeLogs, { immediate: true });
</script>

<template>
  <div v-if="isLoading" class="flex items-center justify-center py-8">
    <UIcon name="i-heroicons-arrow-path" class="text-muted animate-spin text-4xl" />
  </div>
  <div v-else-if="tradeLogs.length === 0" class="text-muted flex items-center justify-center py-8">
    <p>No trades found</p>
  </div>
  <div v-else class="space-y-4 divide-y divide-white/5 py-4">
    <div v-for="log in tradeLogs" :key="log.hash" class="fbc pb-2">
      <div class="flex-1">
        <UUser
          :to="`https://x.com/${log.user_slug}`"
          target="_blank"
          :name="log.user_name || 'Unknown'"
          size="xl"
          :avatar="{
            src: log.user_avatar,
          }"
          :ui="{
            name: 'text-sm',
            description:
              log.trade_type === 'buy' ? 'text-md text-green-400' : 'text-md text-red-400',
          }"
        >
          <template #description>
            <div class="text-xs">
              {{ log.trade_type === "buy" ? "Buy" : "Sell" }}
              <TimeAgo :time="log.created_at" />
            </div>
          </template>
        </UUser>
      </div>
      <div class="text-right">
        <div class="text-sm font-medium text-white">
          Price: {{ formatNumber(formatEther(log.price)) }} $PCT
        </div>
        <div class="text-xs text-white/50">
          <UButton
            :to="useExplorerUrl(network, `/tx/${log.hash}`)"
            target="_blank"
            variant="link"
            color="neutral"
          >
            {{ shortAddress(log.hash) }}
          </UButton>
        </div>
      </div>
    </div>
  </div>
</template>
