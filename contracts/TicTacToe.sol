// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract TicTacToe {
    uint[9] private board;
    uint private numTurns;

    address payable private _player1;
    address payable private _player2;
    address payable private _currentPlayer;

    mapping(address playerAddress => uint amount) public balances;

    event GameState(uint[9], uint, address);
    event GameBoard(uint[9]);

    modifier isPlayer() {
        require((msg.sender == _player1 || msg.sender == _player2), "please join game if there's an available space");
        _;
    }

    modifier squareIsValid(uint _index) {
        require((board[_index] == 0), "not valid square");
        _;
    }

    function deposit() public payable isPlayer {
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
        // check rows ---- board indexes [0, 1, 2], [3, 4, 5], [6, 7, 8]
        for (uint i = 0; i <= 6; i += 3) {
            if (board[i] == 0) {
                continue;
            }
            if (board[i] == board[i + 1] && board[i] == board[i + 2]) {
                return true;
            }
        }
        // check columns ---- board indexes [0, 3, 6], [1, 4, 7], [2, 5, 8]
        for (uint i = 0; i <= 3; i++) {
            if (board[i] == 0) {
                continue;
            }
            if (board[i] == board[i + 3] && board[i] == board[i + 6]) {
                return true;
            }
        }
        // check diagonals ---- board indexes [0, 4, 8], [2, 4, 6]
        if (board[0] != 0 && board[0] == board[4] && board[0] == board[8]) {
            return true;
        }
        if (board[2] != 0 && board[2] == board[4] && board[2] == board[6]) {
            return true;
        }
        return false;
    }

    function toggleCurrentPlayer() public {
        _currentPlayer = _currentPlayer == _player1 ? _player2 : _player1;
    }

    function resetBoard() public {
        delete board;
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

    function getBoard() public view returns (uint[9] memory) {
        return board;
    }

    function getBoardEvent() public {
        emit GameBoard(board);
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
