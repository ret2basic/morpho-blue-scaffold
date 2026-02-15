// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";
import {MockERC20} from "@recon/MockERC20.sol";

import "src/Morpho.sol";

abstract contract MorphoTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///
     function morpho_liquidate_clamped_by_assets(uint256 seizedAssets) public {
       morpho_liquidate(_getActor(), seizedAssets, 0, hex"");
    }

     function morpho_liquidate_clamped_by_shares(uint256 repaidShares) public {
       morpho_liquidate(_getActor(), 0, repaidShares, hex"");
    }

    function morpho_supply_clamped_by_assets(uint256 assets) public {
        morpho_supply(assets, 0, _getActor(), hex"");
    }

    function morpho_supply_clamped_by_shares(uint256 shares) public {
        morpho_supply(0, shares, _getActor(), hex"");
    }

    function morpho_supplyCollateral_clamped(uint256 assets) public {
        morpho_supplyCollateral(assets, _getActor(), hex"");
    }

    function morpho_repay_clamped_by_assets(uint256 assets) public {
        morpho_repay(assets, 0, _getActor(), hex"");
    }

    function morpho_repay_clamped_by_shares(uint256 shares) public {
        morpho_repay(0, shares, _getActor(), hex"");
    }

    function morpho_borrow_clamped_by_assets(uint256 assets) public {
        morpho_borrow(assets, 0, _getActor(), _getActor());
    }

    function morpho_borrow_clamped_by_shares(uint256 shares) public {
        morpho_borrow(0, shares, _getActor(), _getActor());
    }

    function morpho_withdraw_clamped_by_assets(uint256 assets) public {
        morpho_withdraw(assets, 0, _getActor(), _getActor());
    }

    function morpho_withdraw_clamped_by_shares(uint256 shares) public {
        morpho_withdraw(0, shares, _getActor(), _getActor());
    }

    function morpho_withdrawCollateral_clamped(uint256 assets) public {
        morpho_withdrawCollateral(assets, _getActor(), _getActor());
    }

    function morpho_flashLoan_clamped(uint256 assets) public {
        uint256 balance = MockERC20(marketParams.loanToken).balanceOf(address(morpho));
        if (balance == 0) return;

        uint256 clamped = assets % (balance + 1);
        flashLoanReceiver.executeFlashLoan(morpho, marketParams.loanToken, clamped);
    }

    function morpho_createMarket_clamped(uint8 index, uint256 lltv) public {
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

        if (!morpho.isLltvEnabled(clampedLltv) && morpho.owner() == address(this)) {
            vm.prank(address(this));
            morpho.enableLltv(clampedLltv);
        }

        marketParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: address(oracle),
            irm: address(irm),
            lltv: clampedLltv
        });

        morpho_createMarket(marketParams);
    }

    function morpho_createMarket(MarketParams memory _marketParams) public asActor {
        morpho.createMarket(_marketParams);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function morpho_accrueInterest() public asActor {
        morpho.accrueInterest(marketParams);
    }

    function morpho_borrow(uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_createMarket() public asActor {
        morpho.createMarket(marketParams);
    }

    function morpho_enableIrm(address irm) public asActor {
        morpho.enableIrm(irm);
    }

    function morpho_enableLltv(uint256 lltv) public asActor {
        morpho.enableLltv(lltv);
    }

    function morpho_flashLoan(address token, uint256 assets, bytes memory data) public asActor {
        morpho.flashLoan(token, assets, data);
    }

    function morpho_liquidate(address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public asActor {
        morpho.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
    }

    function morpho_repay(uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        morpho.repay(marketParams, assets, shares, onBehalf, data);
    }
    
    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public asActor {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(Authorization memory authorization, Signature memory signature) public asActor {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_setFee(uint256 newFee) public asActor {
        morpho.setFee(marketParams, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public asActor {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_setOwner(address newOwner) public asActor {
        morpho.setOwner(newOwner);
    }

    function morpho_supply(uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        morpho.supply(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_supplyCollateral(uint256 assets, address onBehalf, bytes memory data) public asActor {
        morpho.supplyCollateral(marketParams, assets, onBehalf, data);
    }

    function morpho_withdraw(uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.withdraw(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(uint256 assets, address onBehalf, address receiver) public asActor {
        morpho.withdrawCollateral(marketParams, assets, onBehalf, receiver);
    }
}