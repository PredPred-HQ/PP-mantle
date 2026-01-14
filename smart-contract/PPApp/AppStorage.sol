// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {IAppStorage} from "./IAppStorage.sol";

contract AppStorage is IAppStorage {
    struct Storage {
        uint256 totalMarket;
        mapping(uint256 => bytes32) marketDigestList;
        mapping(bytes32 => bool) marketDigestMap;
        mapping(bytes32 => Market) marketMap;
        address pctAddress; // Pred Credit: used for buy Yes/No
        uint256 pctDecimals;
        address pftAddress; // Pred Token: only you failed to get $PT
    }
    Storage internal s;

    uint256 constant MAX_ID = 2 ** 256 - 2;
}
