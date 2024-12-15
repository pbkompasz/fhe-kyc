import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/types";

import type { BasicIdentityStrategy } from "../../types";
import { getSigners } from "../signers";

export async function deployStrategy(storageContract: Storage, owner: Address): Promise<BasicIdentityStrategy> {
  const signers = await getSigners();

  const factory = await ethers.getContractFactory("BasicIdentityStrategy");
  const contract = await factory.connect(signers.alice).deploy(storageContract.getAddress(), owner);
  await contract.waitForDeployment();

  return contract;
}
