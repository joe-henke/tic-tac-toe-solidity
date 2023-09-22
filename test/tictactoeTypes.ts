import type { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/dist/src/signer-with-address";

import type { TicTacToe } from "../types/TicTacToe";

type Fixture<T> = () => Promise<T>;

declare module "mocha" {
  export interface Context {
    tictactoe: TicTacToe;
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
    signers: Signers;
  }
}

export interface Signers {
  owner: SignerWithAddress;
  player1: SignerWithAddress;
  player2: SignerWithAddress;
}
