import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("task:deployTicTacToe").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  console.log("beginning deploy");
  const signers = await ethers.getSigners();
  const tictactoeFactory = await ethers.getContractFactory("TicTacToe");
  const tictactoe = await tictactoeFactory.connect(signers[0]).deploy();
  await tictactoe.waitForDeployment();
  console.log("beginning deploy");
  console.log("Tic Tac Toe deployed to: ", await tictactoe.getAddress());
});
