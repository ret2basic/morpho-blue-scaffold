// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Id, MarketParams, Market} from "src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import {MAX_FEE} from "src/libraries/ConstantsLib.sol";
import {MockERC20} from "@recon/MockERC20.sol";

abstract contract Properties is BeforeAfter, Asserts {
	using MarketParamsLib for MarketParams;

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
			uint128 totalSupplyAssets,
			uint128 totalSupplyShares,
			uint128 totalBorrowAssets,
			uint128 totalBorrowShares,
			uint128 lastUpdate,
			
		) = morpho.market(id);

		if (lastUpdate == 0) return;

		if (totalBorrowShares == 0) {
			eq(uint256(totalBorrowAssets), 0, "market: borrow assets without shares");
		}

		if (totalSupplyShares == 0) {
			eq(uint256(totalSupplyAssets), 0, "market: supply assets without shares");
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
		eq(balance + uint256(totalBorrowAssets), uint256(totalSupplyAssets), "market: loan balance mismatch");
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
}