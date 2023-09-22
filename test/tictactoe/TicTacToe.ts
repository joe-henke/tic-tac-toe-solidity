// import { constants } from "@openzeppelin/test-helpers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

import type { Signers } from "../tictactoeTypes";
import { deployTicTacToeFixture } from "./TicTacToe.fixture";
import { BOARD, MOVE1, WINNING_SQUARES, ZERO_ADDRESS } from "./TicTacToeConstants";

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
    expect((await this.tictactoe.seeBoard()).toString()).to.equal(BOARD);
  });
  it("should initialize rows with winning combinations", async function () {
    const rows = await this.tictactoe.seeRows();
    rows.forEach((row, index) => {
      expect(row.toString()).to.equal(WINNING_SQUARES[index]);
    });
  });
  it("should assign first connecting address to player1", async function () {
    const addr1 = (await this.tictactoe.seePlayers())[0];
    expect(addr1).to.equal(this.signers.player1.address);
    expect(addr1).not.equal(this.signers.owner.address);
    expect(addr1).not.equal(this.signers.player2.address);
  });
  it("should assign second connecting address to player2", async function () {
    const addr2 = (await this.tictactoe.seePlayers())[1];
    expect(addr2).to.equal(this.signers.player2.address);
    expect(addr2).not.equal(this.signers.owner.address);
    expect(addr2).not.equal(this.signers.player1.address);
  });
  it("should reset player assignments when calling resetPlayers", async function () {
    await this.tictactoe.resetPlayers();
    const addr1 = (await this.tictactoe.seePlayers())[0];
    const addr2 = (await this.tictactoe.seePlayers())[1];
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
    expect(await this.tictactoe.seeCurrentPlayer()).to.equal(this.signers.player1.address);
  });
  it("should be able to toggle the current player", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.toggleCurrentPlayer();
    expect(await this.tictactoe.seeCurrentPlayer()).to.equal(this.signers.player2.address);
  });
});

describe("TicTacToe Movement", function () {
  deployContract();
  it("should enable players to set squares on the board", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
    expect((await this.tictactoe.seeBoard()).toString()).to.equal(MOVE1);
  });

  it("should assign current player to player2 after player1 move", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
    expect(await this.tictactoe.seeCurrentPlayer()).to.equal(this.signers.player2.address);
  });
  it("should keep a running total or turns", async function () {
    await this.tictactoe.startGame();
    await this.tictactoe.connect(this.signers.player1).move(0);
  });
});
