// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {IAppStorage} from "../IAppStorage.sol";

interface IAdminBase is IAppStorage {
    event UpdatePlatformMeta(PlatformMeta pm);
}
