// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {IAppStorage} from "../IAppStorage.sol";

interface IMarketBase is IAppStorage {
    // createMarket
    error MarketAlreadyExists(bytes32 digest);
    error MaxMarketReached(uint256 currentNftId);
    // buy
    error MarketNotExists(bytes32 digest);
    error MarketNotEnabled(bytes32 digest);
    error MarketShouldEnded(bytes32 digest);
    error MarketAlreadyFinalized(bytes32 digest);
    error MarketEnded(bytes32 digest);
    error InvalidNftId(bytes32 digest, uint256 nftId);
    error MarketShouldFinalized(bytes32 digest);
    error PaymentTransferFailed(bytes32 digest, address payer, address receiver, address tokenAddress, uint256 amount);
    error UserBalanceZero(bytes32 digest, uint256 nftId, address user);

    // event
    event CreateMarket(bytes32 indexed digest, Market marketData);
    event UpdateMarket(bytes32 indexed digest, Market marketData);
    event ToggleMarket(bytes32 indexed digest, Market marketData);
    event EndMarket(bytes32 indexed digest, Market marketData);
    event FinalizeMarket(bytes32 indexed digest, Market marketData);
    event Buy(address indexed buyer, bytes32 indexed digest, uint256 nftId, uint256 targetSupply, uint256 price, uint256 platformFee);
    event Sell(address indexed seller, bytes32 indexed digest, uint256 nftId, uint256 targetSupply, uint256 price);
    event ClaimReward(address indexed user, bytes32 indexed digest, uint256 nftBalance, uint256 rewardAmount, uint256 pcTokenAmount);
    event ClaimFailedToken(address indexed user, bytes32 indexed digest, uint256 failedNftId, uint256 nftBalance);
    event WithdrawPlatformFee(bytes32 indexed digest, address indexed to, uint256 platformFeeAmount);
}
