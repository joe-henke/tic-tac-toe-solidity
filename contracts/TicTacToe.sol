// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract TicTacToe {
    uint[9] private _board;
    uint private _numTurns;

    address payable private _player1;
    address payable private _player2;
    address payable private _currentPlayer;

    mapping(address playerAddress => uint amount) public balances;

    /**
     * @dev GameState is emitted after each move and is intended to update the frontend
     * @notice event to report game state: the board, amount of turns, current player, and if there's a win/tie
     */
    event GameState(uint[9], uint, address, bool);
    event GameBoard(uint[9]);
    event CurrentPlayer(address);

    /**
     * @dev modifier to determine if msg.sender is a registered player
     */
    modifier isPlayer() {
        require((msg.sender == _player1 || msg.sender == _player2), "please join game if there's an available space");
        _;
    }

    /**
     * @dev modifier to determine if square is available for a value
     */
    modifier squareIsValid(uint _index) {
        require((_board[_index] == 0), "not valid square");
        _;
    }

    /**
     * @dev modifier to determine if player is _currentPlayer
     */
    modifier isCurrentPlayer(address _player) {
        require((_player == _currentPlayer), "not current player");
        _;
    }

    /**
     * @dev This method enables the player to deposit a wager. The isPlayer modifier confirms the depositor is a player who has joined the game
     * @notice executes a move on the board by the current player
     */
    function deposit() public payable isPlayer {
        balances[msg.sender] += msg.value;
    }

    /**
     * @dev players join the game to register their account address with the game. Players are then assigned a value of 1 or 2 that they use to mark the squares. How this maps to "X" or "O" is dependent on presentation logic.
     * @notice method to enable player to join the game
     */
    function joinGame() public {
        address payable player = payable(msg.sender);
        if (_player1 == address(0)) {
            _player1 = player;
        } else if (_player2 == address(0)) {
            _player2 = player;
            startGame();
        }
    }

    /**
     * @dev method to reset the board and all parameters and start a fresh game. Allows for resetting the game on the frontend. This method is called after the second player joins the game.
     * @notice method to enable frontend to start game
     */
    function startGame() public {
        resetBoard();
        _currentPlayer = _player1;
        _numTurns = 1;
    }

    /**
     * @param _index index of the "board" array. Board can be presented as a 3x3 board, but board is evaluated as an array.
     * @dev This method is used for determining if the board is in a win or tie state, called after every move. Modifiers require that the board index not be occupied by a value (i.e., it's empty), and that the player executing the move is the current player.
     * @notice executes a move on the board by the current player
     */
    function move(uint _index) public squareIsValid(_index) isCurrentPlayer(msg.sender) {
        uint value = _currentPlayer == _player1 ? 1 : 2;
        _board[_index] = value;
        bool winnerOrTie = checkWinner();
        emit GameState(_board, _numTurns, _currentPlayer, winnerOrTie);
        ++_numTurns;
        if (winnerOrTie) {
            transferBalanceToWinner(_currentPlayer);
            resetGame();
        }
        if (!winnerOrTie && _numTurns == 9) {
            transferBalanceToPlayers();
            resetGame();
        }
        toggleCurrentPlayer();
    }

    /**
     * @dev This method is used for determining if the board is in a win or tie state, called after every move
     * @notice Check board for winner or tie
     * @return bool
     */
    function checkWinner() public view returns (bool) {
        // check rows ---- board indexes [0, 1, 2], [3, 4, 5], [6, 7, 8]
        for (uint i = 0; i <= 6; i += 3) {
            if (_board[i] == 0) {
                continue;
            }
            if (_board[i] == _board[i + 1] && _board[i] == _board[i + 2]) {
                return true;
            }
        }
        // check columns ---- board indexes [0, 3, 6], [1, 4, 7], [2, 5, 8]
        for (uint i = 0; i <= 3; i++) {
            if (_board[i] == 0) {
                continue;
            }
            if (_board[i] == _board[i + 3] && _board[i] == _board[i + 6]) {
                return true;
            }
        }
        // check diagonals ---- board indexes [0, 4, 8], [2, 4, 6]
        if (_board[0] != 0 && _board[0] == _board[4] && _board[0] == _board[8]) {
            return true;
        }
        if (_board[2] != 0 && _board[2] == _board[4] && _board[2] == _board[6]) {
            return true;
        }
        return false;
    }

    function toggleCurrentPlayer() public {
        _currentPlayer = _currentPlayer == _player1 ? _player2 : _player1;
        emit CurrentPlayer(_currentPlayer);
    }

    function resetBoard() public {
        delete _board;
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

    function resetBalances() private {
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
        return _board;
    }

    function getBoardEvent() public {
        emit GameBoard(_board);
    }

    function getCurrentPlayerEvent() public {
        emit CurrentPlayer(_currentPlayer);
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
        return _numTurns;
    }

    /**
     * @notice getter to return current player for testing purposes
     */
    function getCurrentPlayer() public view returns (address) {
        return _currentPlayer;
    }
}
