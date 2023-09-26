import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("task:deployGreeter")
  .addParam("greeting", "Say hello, be nice")
  .setAction(async function (taskArguments: TaskArguments, { ethers }) {
    const signers = await ethers.getSigners();
    const greeterFactory = await ethers.getContractFactory("Greeter");
    const greeter = await greeterFactory.connect(signers[0]).deploy(taskArguments.greeting);
    await greeter.waitForDeployment();
    console.log("Greeter deployed to: ", await greeter.getAddress());
  });

task("task:deployTicTacToe").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers = await ethers.getSigners();
  const tictactoeFactory = await ethers.getContractFactory("TicTacToe");
  const tictactoe = await tictactoeFactory.connect(signers[0]).deploy();
  await tictactoe.waitForDeployment();
  console.log("Tic Tac Toe deployed to: ", await tictactoe.getAddress());
});
