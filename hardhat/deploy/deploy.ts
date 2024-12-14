import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, getOrNull } = hre.deployments;

  // Check if contract was previously deployed
  const isNewMulticall = !(await getOrNull("Multicall"));
  const isNewStorage = !(await getOrNull("Storage"));
  const isNewRegistry = !(await getOrNull("Registry"));

  const deployedMulticall = await deploy("Multicall", {
    from: deployer,
    args: [],
    log: true,
  });

  const deployedStorage = await deploy("Storage", {
    from: deployer,
    args: [],
    log: true,
  });
  const deployedRegistry = await deploy("Registry", {
    from: deployer,
    args: [deployedStorage.address],
    log: true,
  });

  console.log(`Multicall contract: `, deployedMulticall.address);
  console.log(`Storage contract: `, deployedStorage.address);
  console.log(`Registry contract: `, deployedRegistry.address);
};
export default func;
func.id = "deploy_confidentialERC20"; // id required to prevent reexecution
func.tags = ["MyConfidentialERC20"];
