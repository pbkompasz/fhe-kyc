import { ethers } from "hardhat";

import type { KYC, Storage } from "../../types";
import { getSigners } from "../signers";
import { Address } from "hardhat-deploy/types";

export async function deployKyc(storageContract: Storage, owner: Address): Promise<KYC> {
  const signers = await getSigners();

  const factory = await ethers.getContractFactory("KYC");
  const contract = await factory.connect(signers.alice).deploy(0, owner, storageContract.getAddress());
  await contract.waitForDeployment();

  return contract;
}
