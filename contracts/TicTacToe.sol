// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract TicTacToe {
    uint[] private board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    uint[3][8] private winningTiles;
    uint private numTurns;

    address payable private _player1;
    address payable private _player2;
    address payable private _currentPlayer;

    mapping(address playerAddress => uint amount) public balances;

    constructor() {
        winningTiles[0] = [1, 2, 3];
        winningTiles[1] = [4, 5, 6];
        winningTiles[2] = [7, 8, 9];
        winningTiles[3] = [1, 4, 7];
        winningTiles[4] = [2, 5, 8];
        winningTiles[5] = [3, 6, 9];
        winningTiles[6] = [1, 5, 9];
        winningTiles[7] = [3, 5, 7];
    }

    modifier isPlayer() {
        require((msg.sender == _player1 || msg.sender == _player2), "not a player in this game");
        _;
    }

    modifier squareIsValid(uint _index) {
        require((_index < board.length && board[_index] == 0), "not valid square");
        _;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function joinGame() public {
        address payable player = payable(msg.sender);
        if (_player1 == address(0)) {
            _player1 = player;
        } else if (_player2 == address(0)) {
            _player2 = player;
            startGame();
        }
    }

    function startGame() public {
        resetBoard();
        _currentPlayer = _player1;
        numTurns = 1;
    }

    function move(uint _index) public squareIsValid(_index) {
        uint value = _currentPlayer == _player1 ? 1 : 2;
        board[_index] = value;
        ++numTurns;
        if (checkWinner()) {
            transferBalanceToWinner(_currentPlayer);
            resetGame();
        }
        if (!checkWinner() && numTurns == 9) {
            transferBalanceToPlayers();
            resetGame();
        }
        toggleCurrentPlayer();
    }

    function checkWinner() public view returns (bool) {
        uint[] memory checkBoard = board;
        uint[3][8] memory checkWinnningTiles = winningTiles;
        for (uint i = 0; i < 8; i++) {
            uint x = checkBoard[checkWinnningTiles[i][0] - 1];
            uint y = checkBoard[checkWinnningTiles[i][1] - 1];
            uint z = checkBoard[checkWinnningTiles[i][2] - 1];
            if (x == 0) {
                continue;
            }
            if (x == y && y == z) {
                return true;
            }
        }
        return false;
    }

    function toggleCurrentPlayer() public {
        _currentPlayer = _currentPlayer == _player1 ? _player2 : _player1;
    }

    function resetBoard() public {
        board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    }

    function resetPlayers() public {
        _player1 = payable(address(0));
        _player2 = payable(address(0));
    }

    function transferBalanceToWinner(address payable _to) public payable {
        _to.transfer(address(this).balance);
        resetBalances();
    }

    function transferBalanceToPlayers() public payable {
        _player1.transfer(balances[_player1]);
        _player2.transfer(balances[_player2]);
        resetBalances();
    }

    function resetGame() public {
        resetBoard();
        resetPlayers();
        resetBalances();
    }

    function resetBalances() public {
        delete balances[_player1];
        delete balances[_player2];
    }

    // getters

    function getBalance() public view returns (uint) {
        return address(this).balance / 1000000000000000000;
    }

    function getPot() public view returns (uint) {
        return balances[_player1] + balances[_player2];
    }

    function getBoard() public view returns (uint[] memory) {
        return board;
    }

    function getWinningTiles() public view returns (uint[3][8] memory) {
        return winningTiles;
    }

    /**
     * @notice getter to return a array containing both players for testing
     */
    function getPlayers() public view returns (address[] memory) {
        address[] memory playerAddresses = new address[](2);
        playerAddresses[0] = _player1;
        playerAddresses[1] = _player2;
        return playerAddresses;
    }

    /**
     * @notice getter to return number of turns that have elapsed
     */
    function getNumberOfTurns() public view returns (uint) {
        return numTurns;
    }

    /**
     * @notice getter to return current player for testing purposes
     */
    function getCurrentPlayer() public view returns (address) {
        return _currentPlayer;
    }
}
