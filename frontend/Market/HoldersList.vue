<script setup lang="ts">
  const props = defineProps<{
    digest: string;
  }>();

  const holders = ref<any[]>([]);
  const isLoading = ref(false);
  const { network } = $(walletStore());

  const fetchHolders = async () => {
    isLoading.value = true;
    try {
      const response = await $fetch("/api/trade/holders", {
        query: {
          digest: props.digest,
        },
      });
      holders.value = response.data || [];
    } catch (error) {
      console.error("Failed to fetch holders:", error);
      holders.value = [];
    } finally {
      isLoading.value = false;
    }
  };

  watch(() => props.digest, fetchHolders, { immediate: true });
</script>

<template>
  <div v-if="isLoading" class="flex items-center justify-center py-8">
    <UIcon name="i-heroicons-arrow-path" class="text-muted animate-spin text-4xl" />
  </div>
  <div v-else-if="holders.length === 0" class="text-muted flex items-center justify-center py-8">
    <p>No holders found</p>
  </div>
  <div v-else class="space-y-4 divide-y divide-white/5 py-4">
    <div v-for="holder in holders" :key="holder.uid" class="fbc pb-2">
      <UUser
        :to="`https://x.com/${holder.user_slug}`"
        target="_blank"
        :name="holder.user_name || 'Unknown'"
        :description="`Yes: ${holder.yes} | No: ${holder.no}`"
        size="xl"
        :avatar="{
          src: holder.user_avatar,
        }"
        :ui="{ name: 'text-sm', description: 'text-xs' }"
      />
      <div class="text-right">
        <div class="text-sm font-medium text-white">
          Total Spend: {{ formatNumber(formatEther(holder.total_spend)) }} $PCT
        </div>
        <div class="text-xs text-white/50">
          <UButton
            :to="useExplorerUrl(network, `/address/${holder.wallet_address}`)"
            target="_blank"
            variant="link"
          >
            {{ shortAddress(holder.wallet_address) }}
          </UButton>
        </div>
      </div>
    </div>
  </div>
</template>
