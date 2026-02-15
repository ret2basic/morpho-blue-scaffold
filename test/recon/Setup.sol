// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";

// Your deps
import "src/Morpho.sol";
import "src/mocks/MockIRM.sol";
import "src/mocks/OracleMock.sol";
import "@recon/MockERC20.sol";
import {FlashLoanReceiver} from "./FlashLoanReceiver.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    using MarketParamsLib for MarketParams;

    Morpho morpho;

    // Mocks
    MockIRM irm;
    OracleMock oracle;
    FlashLoanReceiver flashLoanReceiver;

    // This is an optimization to avoid having to pass the whole struct as argument in target functions
    MarketParams marketParams;

    // Market tracking for MarketManager
    Id[] internal _createdMarketIds;
    MarketParams[] internal _createdMarkets;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        morpho = new Morpho(_getActor()); // _getActor() returns address(this), the address of Setup contract

        // Deploy Mocks
        irm = new MockIRM();
        oracle = new OracleMock();
        flashLoanReceiver = new FlashLoanReceiver();
        
        // Deploy assets
        _newAsset(18); // collateral token
        _newAsset(18); // loan token

        // Enable IRM and LLTV
        morpho.enableIrm(address(irm));
        morpho.enableLltv(8e17); // 80% liquidation loan-to-value

        // Create and track the default market
        address[] memory assets = _getAssets();
        marketParams = MarketParams({
            loanToken: assets[1],
            collateralToken: assets[0],
            oracle: address(oracle),
            irm: address(irm),
            lltv: 8e17
        });
        morpho.createMarket(marketParams);
        _createdMarkets.push(marketParams);
        _createdMarketIds.push(marketParams.id());

        // Mint the tokens we're using in the system to our actors and
        // approve the Morpho contract to spend them
        _setupAssetsAndApprovals();
    }

    function _setupAssetsAndApprovals() internal {
        address[] memory actors = _getActors();
        uint256 amount = type(uint88).max;
        
        // Process each asset separately to reduce stack depth
        for (uint256 assetIndex = 0; assetIndex < _getAssets().length; assetIndex++) {
            address asset = _getAssets()[assetIndex];
            
            // Mint to actors
            for (uint256 i = 0; i < actors.length; i++) {
                vm.prank(actors[i]);
                MockERC20(asset).mint(actors[i], amount);
            }
            
            // Approve to morpho
            for (uint256 i = 0; i < actors.length; i++) {
                vm.prank(actors[i]);
                MockERC20(asset).approve(address(morpho), type(uint88).max);
            }
        }
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor
    
    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(address(_getActor()));
        _;
    }
}
