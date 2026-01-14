// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Facet} from "../../../Facet.sol";
import {MarketBase} from "./Base.sol";
import {IPPApp_MarketFacet} from "./IFacet.sol";
import "../../../utils/IERC20.sol";
import {AccessControlBase} from "../../../facets/AccessControl/Base.sol";
import {ERC1155Storage} from "../../../facets/ERC1155/Storage.sol";
import {TTOQManagerBase} from "../../../facets/TTOQManager/Base.sol";

contract PPApp_MarketFacet is Facet, AccessControlBase, MarketBase, TTOQManagerBase, IPPApp_MarketFacet {
    function PPApp_MarketFacet_init(uint8 roleA, uint8 roleB, uint8 roleC) external onlyInitializing {
        _setFunctionAccess(this.adminEnableMarket.selector, roleA, true);
        _setFunctionAccess(this.adminWithdrawPlatformFee.selector, roleA, true);
        _setFunctionAccess(this.adminFinalizeMarket.selector, roleA, true);

        _setFunctionAccess(this.createMarket.selector, roleB, true);
        _setFunctionAccess(this.updateMarket.selector, roleB, true);
        _setFunctionAccess(this.endMarket.selector, roleB, true);

        _setFunctionAccess(this.disableMarket.selector, roleC, true);

        _addInterface(type(IPPApp_MarketFacet).interfaceId);
    }

    function createMarket(Market memory marketData) external protected {
        if (s.marketDigestMap[marketData.digest]) revert MarketAlreadyExists(marketData.digest);
        s.marketDigestMap[marketData.digest] = true;

        ERC1155Storage.Storage storage _ds = ERC1155Storage.load();
        if (_ds._idx >= MAX_ID) revert MaxMarketReached(_ds._idx);

        marketData.yesNftId = ++_ds._idx;
        marketData.noNftId = ++_ds._idx;
        s.marketMap[marketData.digest] = marketData;
        s.marketDigestList[s.totalMarket] = marketData.digest;
        s.totalMarket++;

        emit CreateMarket(marketData.digest, marketData);
    }

    function updateMarket(bytes32 digest, Market memory marketData) external protected {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];

        market.resultNftId = marketData.resultNftId;
        market.rewardTotalAmount = marketData.rewardTotalAmount;
        market.isEnabled = marketData.isEnabled;
        market.isEnded = marketData.isEnded;
        market.platformFeeBps = marketData.platformFeeBps;

        emit UpdateMarket(digest, market);
    }

    function disableMarket(bytes32 digest) external protected {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];

        market.isEnabled = false;
        emit ToggleMarket(digest, market);
    }

    function adminEnableMarket(bytes32 digest) external protected {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];

        market.isEnabled = true;
        emit ToggleMarket(digest, market);
    }

    function endMarket(bytes32 digest, uint256 resultNftId) external protected {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (market.isFinalized) revert MarketAlreadyFinalized(digest);
        if (resultNftId != market.yesNftId && resultNftId != market.noNftId) revert InvalidNftId(digest, resultNftId);

        market.isEnded = true;
        market.resultNftId = resultNftId;

        emit EndMarket(digest, market);
    }

    function adminFinalizeMarket(bytes32 digest) external protected {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (!market.isEnded) revert MarketShouldEnded(digest);
        if (market.isFinalized) revert MarketAlreadyFinalized(digest);

        market.isFinalized = true;

        emit FinalizeMarket(digest, market);
    }

    function adminWithdrawPlatformFee(bytes32 digest, address to) external protected {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (!market.isEnabled) revert MarketNotEnabled(digest);

        uint256 platformFeeAmount = market.platformFeeAmount;
        market.platformFeeAmount = 0;
        bool paymentResult = IERC20(s.pctAddress).transfer(to, platformFeeAmount);
        if (!paymentResult) revert PaymentTransferFailed(digest, address(this), to, s.pctAddress, platformFeeAmount);

        emit WithdrawPlatformFee(digest, to, platformFeeAmount);
        emit UpdateMarket(digest, market);
    }

    // public for every one
    function buy(bytes32 digest, uint256 nftId) external {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (!market.isEnabled) revert MarketNotEnabled(digest);
        if (market.isEnded) revert MarketEnded(digest);
        if (nftId != market.yesNftId && nftId != market.noNftId) revert InvalidNftId(digest, nftId);

        uint256 currentSupply = market.yesNftId == nftId ? market.yesSupply : market.noSupply;
        if (market.yesNftId == nftId) {
            market.yesSupply = currentSupply + 1;
        } else {
            market.noSupply = currentSupply + 1;
        }

        uint256 price = _calcPrice(digest, currentSupply + 1);
        bool paymentResult = IERC20(s.pctAddress).transferFrom(msg.sender, address(this), price);
        if (!paymentResult) revert PaymentTransferFailed(digest, msg.sender, address(this), s.pctAddress, price);

        uint256 platformFee = (price * market.platformFeeBps) / 10000;
        market.poolTotalAmount += price - platformFee;
        market.platformFeeAmount += platformFee;
        _mint(msg.sender, nftId, 1, "");
        emit Buy(msg.sender, digest, nftId, currentSupply + 1, price, platformFee);
        emit UpdateMarket(digest, market);
    }

    function sell(bytes32 digest, uint256 nftId) external {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (!market.isEnabled) revert MarketNotEnabled(digest);
        if (market.isEnded) revert MarketEnded(digest);
        if (nftId != market.yesNftId && nftId != market.noNftId) revert InvalidNftId(digest, nftId);

        uint256 currentSupply = market.yesNftId == nftId ? market.yesSupply : market.noSupply;
        if (market.yesNftId == nftId) {
            market.yesSupply = currentSupply - 1;
        } else {
            market.noSupply = currentSupply - 1;
        }
        _burn(msg.sender, nftId, 1);

        uint256 price = _calcPrice(digest, currentSupply);
        uint256 platformFee = (2 * (price * market.platformFeeBps)) / 10000;
        bool paymentResult = IERC20(s.pctAddress).transfer(msg.sender, price - platformFee);
        if (!paymentResult) revert PaymentTransferFailed(digest, address(this), msg.sender, s.pctAddress, price - platformFee);

        market.poolTotalAmount -= price - platformFee;
        emit Sell(msg.sender, digest, nftId, currentSupply - 1, price - platformFee);
        emit UpdateMarket(digest, market);
    }

    function claimReward(bytes32 digest) external {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (!market.isFinalized) revert MarketShouldFinalized(digest);
        if (!market.isEnabled) revert MarketNotEnabled(digest);
        uint256 nftBalance = _balanceOf(msg.sender, market.resultNftId);
        if (nftBalance == 0) revert UserBalanceZero(digest, market.resultNftId, msg.sender);
        _burn(msg.sender, market.resultNftId, nftBalance);

        uint256 resultNftSupply = market.yesNftId == market.resultNftId ? market.yesSupply : market.noSupply;

        // rewardERC20Token
        uint256 rewardAmount = (nftBalance * market.rewardTotalAmount) / resultNftSupply;
        bool paymentResult = IERC20(market.rewardERC20Token).transfer(msg.sender, rewardAmount);
        if (!paymentResult) revert PaymentTransferFailed(digest, address(this), msg.sender, market.rewardERC20Token, rewardAmount);
        market.rewardTotalPayout += rewardAmount;

        // reward $PCT
        uint256 pcTokenAmount = (nftBalance * market.poolTotalAmount) / resultNftSupply;
        paymentResult = IERC20(s.pctAddress).transfer(msg.sender, pcTokenAmount);
        if (!paymentResult) revert PaymentTransferFailed(digest, address(this), msg.sender, s.pctAddress, pcTokenAmount);
        market.pcPayout += pcTokenAmount;

        emit ClaimReward(msg.sender, digest, nftBalance, rewardAmount, pcTokenAmount);
        emit UpdateMarket(digest, market);
    }

    function claimFailedToken(bytes32 digest) external {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        Market storage market = s.marketMap[digest];
        if (!market.isFinalized) revert MarketShouldFinalized(digest);
        if (!market.isEnabled) revert MarketNotEnabled(digest);

        uint256 failedNftId = market.yesNftId == market.resultNftId ? market.noNftId : market.yesNftId;
        uint256 nftBalance = _balanceOf(msg.sender, failedNftId);
        if (nftBalance == 0) revert UserBalanceZero(digest, failedNftId, msg.sender);
        _burn(msg.sender, failedNftId, nftBalance);

        // reward $PFT
        bool paymentResult = IERC20(s.pftAddress).transfer(msg.sender, nftBalance);
        if (!paymentResult) revert PaymentTransferFailed(digest, address(this), msg.sender, s.pftAddress, nftBalance);
        market.ptTokenPayout += nftBalance;

        emit ClaimFailedToken(msg.sender, digest, failedNftId, nftBalance);
        emit UpdateMarket(digest, market);
    }

    // view
    function getMarket(bytes32 digest, uint256 targetSupply) external view returns (Market memory market, PriceMeta memory priceMeta) {
        if (!s.marketDigestMap[digest]) revert MarketNotExists(digest);
        market = s.marketMap[digest];
        priceMeta.targetSupplyPrice = _calcPrice(digest, targetSupply);
        priceMeta.currentYesPrice = _calcPrice(digest, market.yesSupply + 1);
        priceMeta.currentNoPrice = _calcPrice(digest, market.noSupply + 1);
    }

    function getMarketList(uint256 start, uint256 limit) external view returns (bytes32[] memory) {
        uint256 length = limit;
        if (start + limit > s.totalMarket) {
            length = s.totalMarket - start;
        }

        bytes32[] memory result = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = s.marketDigestList[start + i];
        }
        return result;
    }
}
