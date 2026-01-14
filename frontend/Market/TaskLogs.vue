<script setup lang="ts">
  import type { TableColumn } from "@nuxt/ui";

  const { network } = $(walletStore());

  const { item } = $defineProps<{
    item: {
      title: string;
      description: string;
      image: string;
      date: string;
      priceYes: number;
      priceNo: number;
      tokenYesCount: number;
      tokenNoCount: number;
      holdersCount: number;
      authors: {
        to: string;
        target: string;
        avatar: {
          src: string;
        };
      }[];
    };
  }>();
  const UUser = resolveComponent("UUser");
  const UButton = resolveComponent("UButton");

  type User = {
    id: number;
    created_at: string;
    reason: string;
    status: string;
    hash: string;
    twitterInfo: {
      avatar: string;
      name: string;
      slug: string;
    };
  };

  const { rewardList, isRewardLoading, getRewardList } = $(shareToXStore());
  const columns: TableColumn<User>[] = [
    // {
    //   accessorKey: "id",
    //   header: "ID",
    // },
    {
      accessorKey: "twitterInfo",
      header: "User",
      cell: ({ row }) => {
        const { name, slug, avatar: src } = row.getValue("twitterInfo");
        const to = `https://x.com/${slug}`;
        return h(UUser, {
          avatar: { src },
          name,
          to,
          target: "_blank",
        });
      },
    },
    {
      accessorKey: "reward",
      header: "Token",
      cell: () => "10 $PCT",
    },
    // {
    //   accessorKey: "status",
    //   header: "Status",
    // },
    {
      accessorKey: "hash",
      header: "Hash",
      cell: ({ row }) => {
        const hash = row.getValue("hash");
        if (!hash) return "";
        return h(
          UButton,
          {
            to: useExplorerUrl(network, `/tx/${hash}`),
            target: "_blank",
            variant: "link",
          },
          () => shortAddress(hash) || ""
        );
      },
    },
  ];

  onMounted(getRewardList);
</script>

<template>
  <UTable
    ref="table"
    :data="rewardList"
    :columns="columns"
    :loading="isRewardLoading"
    sticky
    class="max-h-152"
  />
</template>

<i18n>{
  "en": {
  
  },
  "zh": {
  }
}
</i18n>
