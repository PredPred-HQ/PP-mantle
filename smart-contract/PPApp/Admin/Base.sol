// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {EIP712Base} from "../../../facets/EIP712/Base.sol";
import {IAdminBase} from "./IBase.sol";
import {AppStorage} from "../AppStorage.sol";
import "../../../utils/IERC20.sol";

abstract contract AdminBase is AppStorage, IAdminBase, EIP712Base {
    
}
