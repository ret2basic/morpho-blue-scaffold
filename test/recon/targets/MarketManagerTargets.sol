// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

import {Id, MarketParams} from "src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";

abstract contract MarketManagerTargets is
    BaseTargetFunctions,
    Properties
{
    using MarketParamsLib for MarketParams;

    /// @dev Create a new market with clamped parameters from governance-approved LLTVs
    function market_createMarket_clamped(uint8 index, uint256 lltv) public {
        address[] memory assets = _getAssets();
        address loanToken = assets[index % assets.length];
        address collateralToken = assets[(index + 1) % assets.length];

        uint256[9] memory approvedLltvs = [
            uint256(0),
            385000000000000000,
            625000000000000000,
            770000000000000000,
            860000000000000000,
            915000000000000000,
            945000000000000000,
            965000000000000000,
            980000000000000000
        ];
        uint256 clampedLltv = approvedLltvs[lltv % approvedLltvs.length];

        // Enable the LLTV if needed (owner-only operation)
        if (!morpho.isLltvEnabled(clampedLltv) && morpho.owner() == address(this)) {
            vm.prank(address(this));
            morpho.enableLltv(clampedLltv);
        }

        MarketParams memory newMarket = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: address(oracle),
            irm: address(irm),
            lltv: clampedLltv
        });

        morpho.createMarket(newMarket);

        // Track the created market and switch to it
        _createdMarkets.push(newMarket);
        _createdMarketIds.push(newMarket.id());
        marketParams = newMarket;
    }

    /// @dev Switch the active market to a previously created one
    function market_switchMarket(uint256 entropy) public {
        require(_createdMarkets.length > 0, "no markets created");
        uint256 idx = entropy % _createdMarkets.length;
        marketParams = _createdMarkets[idx];
    }

    /// @dev Get the number of created markets
    function market_getCreatedCount() public view returns (uint256) {
        return _createdMarketIds.length;
    }
}
