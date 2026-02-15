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

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    Morpho morpho;

    // Mocks
    MockIRM irm;
    OracleMock oracle;
    FlashLoanReceiver flashLoanReceiver;
     // This is an optimization to avoid having to pass the whole struct as argument in target functions
    MarketParams marketParams;

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

        // Create the market 
        morpho.enableIrm(address(irm));
        morpho.enableLltv(8e17); // 80% liquiditation loan-to-value

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
