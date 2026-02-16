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

    // forge test --match-test test_invariant_supply_shares_equal_total_all_markets_siyg -vvv
    
    function test_invariant_supply_shares_equal_total_all_markets_siyg() public {
      
       vm.roll(22);
       vm.warp(22);
       morpho_supply_clamped_by_shares(3061541748046865499);
      
       vm.roll(22);
       vm.warp(22);
       morpho_setFeeRecipient(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
      
       vm.roll(22);
       vm.warp(22);
       invariant_supply_shares_equal_total_all_markets();
    }
   		

// forge test --match-test test_invariant_healthy_positions_at_baseline_price_all_markets_s1ap -vvv
    
    function test_invariant_healthy_positions_at_baseline_price_all_markets_s1ap() public {
      
       vm.roll(22);
       vm.warp(22);
       asset_approve(0x93b76387b1EDe292962031c931E80BD66CE12b3f, 175759876288075898772889446100166232669);
      
       vm.roll(22);
       vm.warp(22);
       invariant_supply_shares_grow_together();
      
       vm.roll(22);
       vm.warp(22);
       morpho_supplyCollateral_clamped(1);
      
       vm.roll(22);
       vm.warp(22);
       invariant_borrow_shares_grow_together();
      
       vm.roll(43086);
       vm.warp(1065401);
       asset_mint(0x8cc1CD66667c16088456B96C7b44256677d1fe00, 325290600514949518584731347182905559080);
      
       vm.roll(45643);
       vm.warp(1073374);
       invariant_healthy_positions_at_baseline_price_all_markets();
      
       vm.roll(46719);
       vm.warp(1653744);
       morpho_accrueInterest();
      
       vm.roll(46719);
       vm.warp(1653744);
       invariant_borrow_shares_grow_together();
      
       vm.roll(94283);
       vm.warp(1738020);
       oracle_setPrice(3334299535152191040228615486326094036656279095820745427150542305044689472385);
      
       vm.roll(138904);
       vm.warp(1848133);
       morpho_borrow_clamped_by_shares(1);
      
       vm.roll(157318);
       vm.warp(1970667);
       market_switchMarket(9360205377197719519518228173579772454092964077950217106894738498235574765261);
      
       vm.roll(157318);
       vm.warp(1970667);
       asset_mint(0x60aEfB325fa687AEFBbDbF502F5635DA19676171, 160);
      
       vm.roll(188062);
       vm.warp(2159728);
       invariant_supply_shares_shrink_together();
      
       vm.roll(188062);
       vm.warp(2159728);
       invariant_supply_shares_grow_together();
      
       vm.roll(188062);
       vm.warp(2159728);
       invariant_borrow_shares_equal_total_all_markets();
      
       vm.roll(188062);
       vm.warp(2159728);
       invariant_collateral_withdraw_reflected_in_balance();
      
       vm.roll(188062);
       vm.warp(2159728);
       morpho_accrueInterest();
      
       vm.roll(188062);
       vm.warp(2159728);
       morpho_setAuthorization(0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9, false);
      
       vm.roll(188983);
       vm.warp(2643246);
       oracle_setPrice(1000000000000000000000000000000000000);
      
       vm.roll(188983);
       vm.warp(2643246);
       invariant_healthy_positions_at_baseline_price_all_markets();
    }
   		
}