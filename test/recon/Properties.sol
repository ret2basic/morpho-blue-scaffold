// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Id, MarketParams} from "src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import {MAX_FEE} from "src/libraries/ConstantsLib.sol";
import {MockERC20} from "@recon/MockERC20.sol";

abstract contract Properties is BeforeAfter, Asserts {
	using MarketParamsLib for MarketParams;

	// ============================================================
	//                     GLOBAL PROPERTIES
	// ============================================================

	function invariant_market_initialized_and_enabled() public {
		Id id = marketParams.id();
		(
			uint128 totalSupplyAssets,
			uint128 totalSupplyShares,
			uint128 totalBorrowAssets,
			uint128 totalBorrowShares,
			uint128 lastUpdate,
			uint128 fee
		) = morpho.market(id);

		if (lastUpdate == 0) {
			eq(uint256(totalSupplyAssets), 0, "market: supply assets without market");
			eq(uint256(totalSupplyShares), 0, "market: supply shares without market");
			eq(uint256(totalBorrowAssets), 0, "market: borrow assets without market");
			eq(uint256(totalBorrowShares), 0, "market: borrow shares without market");
			return;
		}

		lte(uint256(lastUpdate), block.timestamp, "market: lastUpdate in future");
		t(morpho.isIrmEnabled(marketParams.irm), "market: irm not enabled");
		t(morpho.isLltvEnabled(marketParams.lltv), "market: lltv not enabled");
		lte(uint256(fee), MAX_FEE, "market: fee exceeds max");
	}

	function invariant_fee_within_bounds() public {
		Id id = marketParams.id();
		(,,,,, uint128 fee) = morpho.market(id);

		lte(uint256(fee), MAX_FEE, "market: fee exceeds max");
	}

	function invariant_borrow_not_exceed_supply() public {
		Id id = marketParams.id();
		(
			uint128 totalSupplyAssets,
			,
			uint128 totalBorrowAssets,
			,
			uint128 lastUpdate,
			
		) = morpho.market(id);

		if (lastUpdate == 0) return;

		lte(uint256(totalBorrowAssets), uint256(totalSupplyAssets), "market: borrow exceeds supply");
	}

	function invariant_zero_shares_assets_consistent() public {
		Id id = marketParams.id();
		(
			,
			,
			uint128 totalBorrowAssets,
			uint128 totalBorrowShares,
			uint128 lastUpdate,
			
		) = morpho.market(id);

		if (lastUpdate == 0) return;

		if (totalBorrowShares == 0) {
			eq(uint256(totalBorrowAssets), 0, "market: borrow assets without shares");
		}
	}

	function invariant_loan_token_balance_matches() public {
		Id id = marketParams.id();
		(
			uint128 totalSupplyAssets,
			,
			uint128 totalBorrowAssets,
			,
			uint128 lastUpdate,
			
		) = morpho.market(id);

		if (lastUpdate == 0) return;

		uint256 balance = MockERC20(marketParams.loanToken).balanceOf(address(morpho));
		gte(balance + uint256(totalBorrowAssets), uint256(totalSupplyAssets), "market: loan accounting deficit");
	}

	function invariant_market_params_persisted() public {
		Id id = marketParams.id();
		(,,,, uint128 lastUpdate,) = morpho.market(id);

		if (lastUpdate == 0) return;

		(
			address loanToken,
			address collateralToken,
			address oracle,
			address irm,
			uint256 lltv
		) = morpho.idToMarketParams(id);

		eq(uint256(uint160(loanToken)), uint256(uint160(marketParams.loanToken)), "market: loan token mismatch");
		eq(uint256(uint160(collateralToken)), uint256(uint160(marketParams.collateralToken)), "market: collateral token mismatch");
		eq(uint256(uint160(oracle)), uint256(uint160(marketParams.oracle)), "market: oracle mismatch");
		eq(uint256(uint160(irm)), uint256(uint160(marketParams.irm)), "market: irm mismatch");
		eq(lltv, marketParams.lltv, "market: lltv mismatch");
	}

	/// @dev Sum of tracked actors' supply shares must not exceed totalSupplyShares
	function invariant_sum_supply_shares_lte_total() public {
		Id id = marketParams.id();
		(, uint128 totalSupplyShares,,, uint128 lastUpdate,) = morpho.market(id);
		if (lastUpdate == 0) return;

		address[] memory actors = _getActors();
		uint256 sumSupplyShares;
		for (uint256 i = 0; i < actors.length; i++) {
			(uint256 ss,,) = morpho.position(id, actors[i]);
			sumSupplyShares += ss;
		}

		lte(sumSupplyShares, uint256(totalSupplyShares), "market: sum of supply shares exceeds total");
	}

	/// @dev Sum of tracked actors' borrow shares must not exceed totalBorrowShares
	function invariant_sum_borrow_shares_lte_total() public {
		Id id = marketParams.id();
		(,,, uint128 totalBorrowShares, uint128 lastUpdate,) = morpho.market(id);
		if (lastUpdate == 0) return;

		address[] memory actors = _getActors();
		uint256 sumBorrowShares;
		for (uint256 i = 0; i < actors.length; i++) {
			(, uint128 bs,) = morpho.position(id, actors[i]);
			sumBorrowShares += uint256(bs);
		}

		lte(sumBorrowShares, uint256(totalBorrowShares), "market: sum of borrow shares exceeds total");
	}

	/// @dev Morpho's collateral token balance must cover all tracked positions' collateral
	function invariant_collateral_balance_sufficient() public {
		Id id = marketParams.id();
		(,,,, uint128 lastUpdate,) = morpho.market(id);
		if (lastUpdate == 0) return;

		address[] memory actors = _getActors();
		uint256 sumCollateral;
		for (uint256 i = 0; i < actors.length; i++) {
			(,, uint128 c) = morpho.position(id, actors[i]);
			sumCollateral += uint256(c);
		}

		uint256 balance = MockERC20(marketParams.collateralToken).balanceOf(address(morpho));
		gte(balance, sumCollateral, "market: collateral token balance deficit");
	}

	// ============================================================
	//              STATE-CHANGING (INLINED) PROPERTIES
	//       Uses ghost variables updated by `updateGhosts` modifier
	// ============================================================

	/// @dev If actor's supply shares grew, total supply shares must also have grown
	function invariant_supply_shares_grow_together() public {
		if (_after.supplyShares > _before.supplyShares) {
			gt(_after.totalSupplyShares, _before.totalSupplyShares,
				"inlined: position supply shares grew but total didn't");
		}
	}

	/// @dev If actor's supply shares shrank, total supply shares must also have shrank
	function invariant_supply_shares_shrink_together() public {
		if (_after.supplyShares < _before.supplyShares) {
			lt(_after.totalSupplyShares, _before.totalSupplyShares,
				"inlined: position supply shares shrank but total didn't");
		}
	}

	/// @dev If actor's borrow shares grew, total borrow shares must also have grown
	function invariant_borrow_shares_grow_together() public {
		if (_after.borrowShares > _before.borrowShares) {
			gt(_after.totalBorrowShares, _before.totalBorrowShares,
				"inlined: position borrow shares grew but total didn't");
		}
	}

	/// @dev If actor's borrow shares shrank, total borrow shares must also have shrank
	function invariant_borrow_shares_shrink_together() public {
		if (_after.borrowShares < _before.borrowShares) {
			lt(_after.totalBorrowShares, _before.totalBorrowShares,
				"inlined: position borrow shares shrank but total didn't");
		}
	}

	/// @dev lastUpdate should never go backwards
	function invariant_lastUpdate_monotonic() public {
		gte(_after.lastUpdate, _before.lastUpdate,
			"inlined: lastUpdate decreased");
	}

	/// @dev If collateral increased, Morpho's collateral token balance must have increased
	function invariant_collateral_deposit_reflected_in_balance() public {
		if (_after.collateral > _before.collateral) {
			gt(_after.morphoCollateralBalance, _before.morphoCollateralBalance,
				"inlined: collateral grew but morpho balance didn't");
		}
	}

	/// @dev If collateral decreased, Morpho's collateral token balance must have decreased
	function invariant_collateral_withdraw_reflected_in_balance() public {
		if (_after.collateral < _before.collateral) {
			lt(_after.morphoCollateralBalance, _before.morphoCollateralBalance,
				"inlined: collateral shrank but morpho balance didn't");
		}
	}
}