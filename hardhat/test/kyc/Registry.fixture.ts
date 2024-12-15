import { ethers } from "hardhat";

import type { Registry, Storage } from "../../types";
import { getSigners } from "../signers";

export async function deployRegistry(storageContract: Storage): Promise<Registry> {
  const signers = await getSigners();

  const storageFactory = await ethers.getContractFactory("Registry");
  const contract = await storageFactory.connect(signers.alice).deploy(storageContract.getAddress());
  await contract.waitForDeployment();

  return contract;
}
