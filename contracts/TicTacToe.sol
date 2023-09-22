// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract TicTacToe {
    uint[] private board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    uint[3][8] private rows;
    uint private numTurns;

    address payable private _player1;
    address payable private _player2;

    constructor() {
        rows[0] = [1, 2, 3];
        rows[1] = [4, 5, 6];
        rows[2] = [7, 8, 9];
        rows[3] = [1, 4, 7];
        rows[4] = [2, 5, 8];
        rows[5] = [3, 6, 9];
        rows[6] = [1, 5, 9];
        rows[7] = [3, 5, 7];
    }

    function joinGame() public {
        address payable player = payable(msg.sender);
        if (_player1 == address(0)) {
            _player1 = player;
        } else if (_player2 == address(0)) {
            _player2 = player;
        }
    }
}
