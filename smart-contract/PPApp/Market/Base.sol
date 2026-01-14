// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {EIP712Base} from "../../../facets/EIP712/Base.sol";
import {ERC1155Base} from "../../../facets/ERC1155/Base.sol";
import {IMarketBase} from "./IBase.sol";
import {AppStorage} from "../AppStorage.sol";
import {UserNonceBase} from "../../../facets/UserNonce/Base.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

abstract contract MarketBase is IMarketBase, AppStorage, ERC1155Base, EIP712Base, UserNonceBase {
    // price = k * sqrt(x) + c
    function _calcPrice(bytes32 digest, uint256 supply) internal view returns (uint256) {
        Market memory market = s.marketMap[digest];
        uint256 k = market.k;
        uint256 c = market.c;
        // TODO: should be sure the precise problem that may cause hack?
        return (k * Math.sqrt(supply * 10 ** (s.pctDecimals * 2))) / (10 ** s.pctDecimals) + c;
    }
}
