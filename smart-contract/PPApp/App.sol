// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Diamond} from "../../Diamond.sol";

contract PPApp is Diamond {
    constructor(InitParams memory initDiamondCut) Diamond(initDiamondCut) {}
}
