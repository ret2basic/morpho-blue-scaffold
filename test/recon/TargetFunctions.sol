// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";
import {ORACLE_PRICE_SCALE} from "src/libraries/ConstantsLib.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

// Targets
// NOTE: Always import and apply them in alphabetical order, so much easier to debug!
import { AdminTargets } from "./targets/AdminTargets.sol";
import { DoomsdayTargets } from "./targets/DoomsdayTargets.sol";
import { ManagersTargets } from "./targets/ManagersTargets.sol";
import { MarketManagerTargets } from "./targets/MarketManagerTargets.sol";
import { MorphoTargets } from "./targets/MorphoTargets.sol";

abstract contract TargetFunctions is
    AdminTargets,
    DoomsdayTargets,
    ManagersTargets,
    MarketManagerTargets,
    MorphoTargets
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///
    function oracle_setPrice(uint256 price) public {
        if (price != ORACLE_PRICE_SCALE) _oracleEverNonBaseline = true;
        oracle.setPrice(price);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///
}
