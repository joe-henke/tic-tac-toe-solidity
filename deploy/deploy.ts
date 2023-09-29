import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  const chainId = network.config.chainId;

  const tictactoe = await deploy("TicTacToe", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: chainId == 31337 ? 1 : 6,
  });

  console.log(`TicTacToe contract: `, tictactoe.address);
};
export default func;
func.id = "deploy_tictactoe"; // id required to prevent reexecution
func.tags = ["TicTacToe"];
