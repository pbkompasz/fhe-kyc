import { ethers } from "hardhat";

import type { Multicall } from "../../types";
import { getSigners } from "../signers";

export async function deployMulticall(): Promise<Multicall> {
  const signers = await getSigners();

  const factory = await ethers.getContractFactory("Multicall");
  const contract = await factory.connect(signers.alice).deploy(); 
  await contract.waitForDeployment();

  return contract;
}
