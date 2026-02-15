// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {IMorphoFlashLoanCallback} from "src/interfaces/IMorphoCallbacks.sol";
import {MockERC20} from "@recon/MockERC20.sol";
import "src/Morpho.sol";

contract FlashLoanReceiver is IMorphoFlashLoanCallback {
    address private _token;
    address private _morpho;

    function executeFlashLoan(Morpho morpho, address token, uint256 assets) external {
        _token = token;
        _morpho = address(morpho);
        morpho.flashLoan(token, assets, hex"01");
        _token = address(0);
        _morpho = address(0);
    }

    function onMorphoFlashLoan(uint256 assets, bytes calldata) external override {
        require(msg.sender == _morpho, "untrusted morpho");
        MockERC20(_token).approve(_morpho, assets);
    }
}
