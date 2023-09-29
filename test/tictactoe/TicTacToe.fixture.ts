import { ethers } from "hardhat";

import type { TicTacToe } from "../../types";
import { TicTacToe__factory } from "../../types/factories/TicTacToe__factory";

export async function deployTicTacToeFixture(): Promise<{ tictactoe: TicTacToe }> {
  const signers = await ethers.getSigners();
  const owner = signers[0];
  const player1 = signers[1];
  const player2 = signers[2];

  const tictactoeFactory = await ethers.getContractFactory("TicTacToe");
  const tictactoe = await tictactoeFactory.connect(owner).deploy();
  tictactoe.connect(player1);
  tictactoe.connect(player2);
  await tictactoe.waitForDeployment();

  return { tictactoe };
}
