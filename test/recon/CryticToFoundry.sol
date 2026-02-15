// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";


// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();

        targetContract(address(this));
    }

    // forge test --match-test test_crytic -vvv
    function test_crytic() public {
        // testing supplying assets to a market as the default actor (address(this))
        morpho_supply_clamped_by_assets(1e18);
        morpho_supplyCollateral_clamped(1e18);
        oracle_setPrice(1e30);
        morpho_borrow(1e6, 0, _getActor(), _getActor());
    }	

    // forge test --match-test test_invariant_loan_token_balance_matches_xqua -vvv
    
    function test_invariant_loan_token_balance_matches_xqua() public {
      
       vm.roll(4555);
       vm.warp(25734);
       morpho_createMarket_clamped(32, 340282366920938463463374607431768211423);
      
       vm.roll(4555);
       vm.warp(25734);
       morpho_supplyCollateral_clamped(3);
      
       vm.roll(4555);
       vm.warp(25734);
       morpho_createMarket_clamped(197, 8979805487611416788647563263232490433988881660629653527024749191978963186536);
      
       vm.roll(39900);
       vm.warp(99795);
       morpho_enableIrm(0xb40a29AFE623c9A9267c15A4DfE4A366310f6025);
      
       vm.roll(39900);
       vm.warp(99795);
       invariant_loan_token_balance_matches();
    }
   		

// forge test --match-test test_invariant_zero_shares_assets_consistent_n99s -vvv
    
    function test_invariant_zero_shares_assets_consistent_n99s() public {
      
       vm.roll(22);
       vm.warp(22);
       invariant_zero_shares_assets_consistent();
      
       vm.roll(23);
       vm.warp(383822);
       morpho_createMarket_clamped(0, 3053351444338649384708826472193337712431103503612226830477146006435592117670);
      
       vm.roll(23);
       vm.warp(383822);
       morpho_setAuthorization(0x353EBD22432E0E0a88f25772CF24eFd3D22C100d, false);
      
       vm.roll(23);
       vm.warp(383822);
       invariant_zero_shares_assets_consistent();
      
       vm.roll(24);
       vm.warp(383823);
       invariant_fee_within_bounds();
      
       vm.roll(24);
       vm.warp(383823);
       morpho_supply_clamped_by_shares(1);
      
       vm.roll(2927);
       vm.warp(468136);
       invariant_borrow_not_exceed_supply();
      
       vm.roll(2927);
       vm.warp(468136);
       morpho_accrueInterest();
      
       vm.roll(2927);
       vm.warp(468136);
       invariant_borrow_not_exceed_supply();
      
       vm.roll(2927);
       vm.warp(468136);
       asset_mint(0x89b6C63e33E153e268c6C9E84c3f8D8D4c339DfE, 1300000000000000000);
      
       vm.roll(7228);
       vm.warp(745826);
    morpho_enableIrm(address(0x20000));
      
       vm.roll(7228);
       vm.warp(745826);
       morpho_setFeeRecipient(0xc7183455a4C133Ae270771860664b6B7ec320bB1);
      
       vm.roll(7228);
       vm.warp(745826);
       invariant_fee_within_bounds();
      
       vm.roll(7228);
       vm.warp(745826);
       morpho_setFeeRecipient(0x9361cD7418Eec8E7cF75B0C157E4F65d0A75fB56);
      
       vm.roll(7229);
       vm.warp(745831);
       morpho_withdraw_clamped_by_shares(1);
      
       vm.roll(71159);
       vm.warp(1372009);
       asset_mint(0x7e50B8D33E73fb9b2eA25a421a077a0cf160c341, 58074731576578536195704050376724304966);
      
       vm.roll(110043);
       vm.warp(1611651);
       oracle_setPrice(115792089237316195423570985008687907853269984665640564039457584007913129639909);
      
       vm.roll(148476);
       vm.warp(2177972);
    morpho_setAuthorization(address(0x30000), true);
      
       vm.roll(188835);
       vm.warp(3366935);
       morpho_setAuthorization(0xC1738bc5D94488a2Ff22D8EF0C561FC7b05a1A77, false);
      
       vm.roll(238318);
       vm.warp(3845860);
       invariant_zero_shares_assets_consistent();
    }	
}