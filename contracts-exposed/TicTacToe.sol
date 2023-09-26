// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/TicTacToe.sol";
import "../hardhat/console.sol";

contract $TicTacToe is TicTacToe {
    bytes32 public constant __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() payable {
    }

    receive() external payable {}
}
