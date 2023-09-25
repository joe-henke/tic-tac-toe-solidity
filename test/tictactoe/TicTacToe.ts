// import { constants } from "@openzeppelin/test-helpers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import type { Signers } from "../tictactoeTypes";
import { deployTicTacToeFixture } from "./TicTacToe.fixture";
import { BOARD, MOVE1, MOVE2, MOVE3, MOVE4, ZERO_ADDRESS } from "./TicTacToeConstants";

function deployContract() {
  before(async function () {
    this.signers = {} as Signers;
    const signers = await ethers.getSigners();
    this.signers.owner = signers[0];
    this.signers.player1 = signers[1];
    this.signers.player2 = signers[2];

    const { tictactoe } = await loadFixture(deployTicTacToeFixture);
    this.tictactoe = tictactoe;
    await this.tictactoe.connect(this.signers.player1).joinGame();
    await this.tictactoe.connect(this.signers.player2).joinGame();
  });
}

describe("TicTacToe Initialization", function () {
  deployContract();
  it("should initialize the board", async function () {
    expect((await this.tictactoe.getBoard()).toString()).to.equal(BOARD);
  });
  it("should assign first connecting address to player1", async function () {
    const addr1 = (await this.tictactoe.getPlayers())[0];
    expect(addr1).to.equal(this.signers.player1.address);
    expect(addr1).not.equal(this.signers.owner.address);
    expect(addr1).not.equal(this.signers.player2.address);
  });
  it("should assign second connecting address to player2", async function () {
    const addr2 = (await this.tictactoe.getPlayers())[1];
    expect(addr2).to.equal(this.signers.player2.address);
    expect(addr2).not.equal(this.signers.owner.address);
    expect(addr2).not.equal(this.signers.player1.address);
  });
  it("should reset player assignments when calling resetPlayers", async function () {
    await this.tictactoe.resetPlayers();
    const addr1 = (await this.tictactoe.getPlayers())[0];
    const addr2 = (await this.tictactoe.getPlayers())[1];
    expect(addr1.toString()).to.equal(ZERO_ADDRESS);
    expect(addr2.toString()).to.equal(ZERO_ADDRESS);
  });
});

describe("TicTacToe Deposit", function () {
  deployContract();
  it("should enable players to deposit funds", async function () {
    await this.tictactoe.connect(this.signers.player1).deposit({ value: ethers.parseEther("1.0") });
    expect((await this.tictactoe.getBalance()).toString()).to.equal("1");
    await this.tictactoe.connect(this.signers.player2).deposit({ value: ethers.parseEther("1.0") });
    expect((await this.tictactoe.getBalance()).toString()).to.equal("2");
  });
});

describe("TicTacToe Start", function () {
  deployContract();
  it("should assign player1 to current player at start of game", async function () {
    await this.tictactoe.startGame();
    expect(await this.tictactoe.getCurrentPlayer()).to.equal(this.signers.player1.address);
  });
  it("should be able to toggle the current player", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.toggleCurrentPlayer();
    expect(await this.tictactoe.getCurrentPlayer()).to.equal(this.signers.player2.address);
  });
});

describe("TicTacToe Movement", function () {
  deployContract();
  it("should enable players to set squares on the board", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
    expect((await this.tictactoe.getBoard()).toString()).to.equal(MOVE1);
  });

  it("should assign current player to player2 after player1 move", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
    expect(await this.tictactoe.getCurrentPlayer()).to.equal(this.signers.player2.address);
  });
  it("should keep a running total or turns", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
    await this.tictactoe.connect(this.signers.player2).move(1);
    await this.tictactoe.connect(this.signers.player1).move(2);
    await this.tictactoe.connect(this.signers.player2).move(3);
    expect(await this.tictactoe.getNumberOfTurns()).to.equal("5");
  });
  it("should update the board with each move", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
    expect((await this.tictactoe.getBoard()).toString()).to.equal(MOVE1);
    await this.tictactoe.connect(this.signers.player2).move(1);
    expect((await this.tictactoe.getBoard()).toString()).to.equal(MOVE2);
    await this.tictactoe.connect(this.signers.player1).move(2);
    expect((await this.tictactoe.getBoard()).toString()).to.equal(MOVE3);
    await this.tictactoe.connect(this.signers.player2).move(3);
    expect((await this.tictactoe.getBoard()).toString()).to.equal(MOVE4);
  });
});

describe("TicTacToe Winning and Tie", function () {
  deployContract();
  it("should end game and transfer funds on winning move", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).deposit({ value: ethers.parseEther("1") });
    await this.tictactoe.connect(this.signers.player2).deposit({ value: ethers.parseEther("1") });
    await this.tictactoe.connect(this.signers.player1).move(0);
    await this.tictactoe.connect(this.signers.player2).move(1);
    await this.tictactoe.connect(this.signers.player1).move(2);
    await this.tictactoe.connect(this.signers.player2).move(3);
    await this.tictactoe.connect(this.signers.player1).move(4);
    await this.tictactoe.connect(this.signers.player2).move(5);
    expect((await this.tictactoe.getBalance()).toString()).to.equal("2");
    await this.tictactoe.connect(this.signers.player1).move(6);
    expect((await this.tictactoe.getBalance()).toString()).to.equal("0");
    // console.log("--------------");
    // console.log(await ethers.provider.getBalance(this.signers.player1));
    // console.log(await ethers.provider.getBalance(this.signers.player2));
    // console.log("p1", (await this.tictactoe.getBalance(this.signers.player1)).toString());
    // console.log("p2", (await this.tictactoe.getBalance(this.signers.player2)).toString());
    // console.log((await this.tictactoe.getBalance(this.signers.player2)).toString());
    // console.log("--------------");
    expect((await this.tictactoe.getBoard()).toString()).to.equal(BOARD);
  });
});

// [0, 1, 2, 3, 5, 4, 6, 8, 7].forEach(async (tile) => {
