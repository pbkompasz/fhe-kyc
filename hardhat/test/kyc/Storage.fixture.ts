import { ethers } from "hardhat";

import type { Storage } from "../../types";
import { getSigners } from "../signers";

export async function deployStorage(): Promise<Storage> {
  const signers = await getSigners();

  const storageFactory = await ethers.getContractFactory("Storage");
  const contract = await storageFactory.connect(signers.alice).deploy();
  await contract.waitForDeployment();

  return contract;
}
