// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAppStorage {
    struct PlatformMeta {
        address pctAddress;
        uint256 pctDecimals;
        address pftAddress;
    }
    struct Market {
        // input from off chain
        bytes32 digest;
        uint256 resultNftId; // upgrade-able
        address rewardERC20Token;
        uint256 rewardTotalAmount; // upgrade-able
        // setup in contract
        uint256 yesNftId;
        uint256 noNftId;
        bool isEnabled; // upgrade-able
        bool isEnded; // upgrade-able
        bool isFinalized; // upgrade-able
        uint256 yesSupply; // 0;
        uint256 noSupply; // 0;
        uint256 k;
        uint256 c;
        uint256 poolTotalAmount;
        uint256 platformFeeBps; // upgrade-able
        uint256 platformFeeAmount;
        // payout for winner
        uint256 rewardTotalPayout;
        uint256 pcPayout;
        // payout for loser
        uint256 ptTokenPayout;
    }

    struct PriceMeta {
        uint256 targetSupplyPrice;
        uint256 currentYesPrice;
        uint256 currentNoPrice;
    }
}
