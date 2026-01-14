<script setup lang="ts">
  import { toRefs } from 'vue'
  import { useQRCode } from '@vueuse/integrations/useQRCode'
  import { useClipboard } from '@vueuse/core'
  
  const props = defineProps<{
    contractAddress: string
  }>()
  
  const { contractAddress } = toRefs(props)
  const { hideModal } = $(modalStore())
  const { t } = useI18n()
  const { copy, copied } = useClipboard()
  
  const qrCodeUrl = useQRCode(contractAddress)
  
  const handleCopy = async () => {
    await copy(contractAddress.value)
  }
</script>

<template>
  <UModal title="Contract Address" size="xl" :show="true" @close="hideModal">
    <template #body>
      <div class="flex flex-col items-center justify-center space-y-8 p-8">
        <!-- QR Code -->
        <div class="bg-white p-4 rounded-lg shadow-lg">
          <img :src="qrCodeUrl" alt="Contract Address QR Code" class="w-64 h-64" />
        </div>
        
        <!-- Contract Address -->
        <div class="w-full space-y-4">
          <div class="text-center">
            <h3 class="text-sm font-medium text-muted-foreground mb-2">{{ t('Contract Address') }}</h3>
            <div class="flex items-center justify-center space-x-2">
              <code class="bg-muted p-3 rounded-lg font-mono text-sm break-all max-w-full">{{ contractAddress }}</code>
              <UButton 
                size="sm" 
                color="primary" 
                variant="solid" 
                @click="handleCopy"
                :icon="copied ? 'i-lucide-check' : 'i-lucide-copy'"
              >
                {{ copied ? t('Copied!') : t('Copy') }}
              </UButton>
            </div>
          </div>
        </div>
        
        <!-- Network Information -->
        <div class="w-full bg-muted p-4 rounded-lg text-center">
          <p class="text-sm text-muted-foreground">{{ t('Use this address to interact with the PredP.red market contract on the blockchain') }}</p>
        </div>
      </div>
    </template>
    
    <template #footer>
      <div class="flex justify-center">
        <UButton size="lg" color="primary" variant="solid" @click="hideModal">
          {{ t('Close') }}
        </UButton>
      </div>
    </template>
  </UModal>
</template>

<i18n>
{
  "en": {
    "Contract Address": "Contract Address",
    "Copy": "Copy",
    "Copied!": "Copied!",
    "Close": "Close",
    "Use this address to interact with the PredP.red market contract on the blockchain": "Use this address to interact with the PredP.red market contract on the blockchain"
  },
  "zh": {
    "Contract Address": "合约地址",
    "Copy": "复制",
    "Copied!": "已复制!",
    "Close": "关闭",
    "Use this address to interact with the PredP.red market contract on the blockchain": "使用此地址在区块链上与 PredP.red 市场合约交互"
  }
}
</i18n>