// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Facet} from "../../../Facet.sol";
import {AdminBase} from "./Base.sol";
import {IAdminFacet} from "./IFacet.sol";
import "../../../utils/IERC20.sol";
import {TTOQManagerBase} from "../../../facets/TTOQManager/Base.sol";
import {AccessControlBase} from "../../../facets/AccessControl/Base.sol";

contract PPApp_AdminFacet is IAdminFacet, AdminBase, AccessControlBase, TTOQManagerBase, Facet {
    function PPApp_AdminFacet_init(uint8 roleA) external onlyInitializing {
        _setFunctionAccess(this.updatePlatformMeta.selector, roleA, true);
        _setFunctionAccess(this.withdrawPFT.selector, roleA, true);

        _addInterface(type(IAdminFacet).interfaceId);
    }

    function updatePlatformMeta(PlatformMeta memory pm) external protected {
        s.pctAddress = pm.pctAddress;
        s.pctDecimals = pm.pctDecimals;
        s.pftAddress = pm.pftAddress; // decimals = 0
        emit UpdatePlatformMeta(pm);
    }

    function withdrawPFT(uint256 amount) external protected {
        bool paymentResult = IERC20(s.pftAddress).transfer(msg.sender, amount);
        require(paymentResult, "PFT withdraw failed");
    }

    function getPlatformMeta() external view returns (PlatformMeta memory pm) {
        pm.pctAddress = s.pctAddress;
        pm.pctDecimals = s.pctDecimals;
        pm.pftAddress = s.pftAddress;
    }
}
