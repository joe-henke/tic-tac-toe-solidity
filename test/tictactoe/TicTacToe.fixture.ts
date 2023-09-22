import { ethers } from "hardhat";

import type { TicTacToe } from "../../types";
import type { TicTacToe__factory } from "../../types";

export async function deployTicTacToeFixture(): Promise<{ tictactoe: TicTacToe }> {
  const [admin] = await ethers.getSigners();

  const tictactoeFactory = await ethers.getContractFactory("TicTacToe");
  const tictactoe = await tictactoeFactory.connect(admin).deploy();
  await tictactoe.waitForDeployment();

  return { tictactoe };
}
