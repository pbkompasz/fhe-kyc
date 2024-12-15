import { expect } from "chai";
import { ethers, network } from "hardhat";

import { awaitAllDecryptionResults, initGateway } from "../asyncDecrypt";
import { createInstance } from "../instance";
import { reencryptEuint64 } from "../reencrypt";
import { getSigners, initSigners } from "../signers";
import { debug } from "../utils";
import { deployKyc } from "./KYC.fixture";
import { deployMulticall } from "./Multicall.fixture";
import { deployRegistry } from "./Registry.fixture";
import { deployStorage } from "./Storage.fixture";
import { deployStrategy } from "./Strategy.fixture";

function stringToBytes(str: string, length: 64 | 256) {
  const encoder = new TextEncoder();
  const encoded = encoder.encode(str);

  if (encoded.length > length) {
    return encoded.slice(0, length);
  } else {
    const padded = new Uint8Array(length);
    padded.set(encoded); // Copy the encoded bytes into the padded array
    return padded;
  }
}

describe("KYC Registry", function () {
  before(async function () {
    await initSigners();
    this.signers = await getSigners();
    await initGateway();

    const multicallContract = await deployMulticall();
    this.multicall = multicallContract;
    const storageContract = await deployStorage();
    this.storage = storageContract;
    const registryContract = await deployRegistry(storageContract);
    this.registry = registryContract;
    this.fhevm = await createInstance();
  });

  it("registry should be empty", async function () {
    expect(await this.registry.getNumberOfInstances()).to.eq(0);
    //   const transaction = await this.erc20.mint(this.signers.alice, 1000);
    //   await transaction.wait();
    //   // Reencrypt Alice's balance
    //   const balanceHandleAlice = await this.erc20.balanceOf(this.signers.alice);
    //   const balanceAlice = await reencryptEuint64(
    //     this.signers.alice,
    //     this.fhevm,
    //     balanceHandleAlice,
    //     this.contractAddress,
    //   );
    //   expect(balanceAlice).to.equal(1000);
    //   const totalSupply = await this.erc20.totalSupply();
    //   expect(totalSupply).to.equal(1000);
  });

  it("should create new instance for user", async function () {
    const signer = this.signers.alice;
    const contractWithSigner = this.registry.connect(signer);
    const transaction = await contractWithSigner.createInstance();
    await transaction.wait();
    expect(await this.registry.getKyc(signer.getAddress())).to.be.not.undefined;
    expect(await this.registry.getNumberOfInstances()).to.eq(1);
  });

  it("should add a 'BasicIdentity' strategy to kyc process", async function () {
    const signer = this.signers.alice;
    const contractWithSigner = this.registry.connect(signer);
    let transaction = await contractWithSigner.createInstance();
    await transaction.wait();
    const kycAddress = await this.registry.getKyc(signer.getAddress());
    expect(kycAddress).to.be.not.undefined;
    const contractABI = [
      "function addStrategy(uint8 strategyType) external",
      "function getStrategy(uint index) public view returns (address)",
    ];
    const kycContract = new ethers.Contract(kycAddress, contractABI, signer);
    transaction = await kycContract.addStrategy(0);
    await transaction.wait();
    const strategyAddress = await kycContract.getStrategy(0);
    expect(strategyAddress).to.be.not.undefined;
  });

  it("should complete a strategy in kyc", async function () {
    const signer = this.signers.alice;
    const strategyContract = await deployStrategy(this.storage, signer.address);

    // Submit encrypted data
    // Error: Packing more than 2048 bits in a single input ciphertext is unsupported
    const instance = await createInstance();
    const input = instance.createEncryptedInput(await strategyContract.getAddress(), signer.address);
    const input1 = instance.createEncryptedInput(await strategyContract.getAddress(), signer.address);
    const input2 = instance.createEncryptedInput(await strategyContract.getAddress(), signer.address);
    const input3 = instance.createEncryptedInput(await strategyContract.getAddress(), signer.address);
    const input4 = instance.createEncryptedInput(await strategyContract.getAddress(), signer.address);
    const dateOfBirthInput = await input.add256(+new Date()).encrypt();
    const firstnameInput = await input1.addBytes256(stringToBytes("Holden", 256)).encrypt();
    const lastnameInput = await input2.addBytes256(stringToBytes("Hiscock", 256)).encrypt();
    const genderInput = await input3.addBool(true).encrypt();
    const nationalityInput = await input4.addBytes64(stringToBytes("DE", 64)).encrypt();

    expect(await strategyContract.isVerified()).to.be.false;

    await strategyContract.submitDob(dateOfBirthInput.handles[0], dateOfBirthInput.inputProof);
    await strategyContract.submitFirstname(firstnameInput.handles[0], firstnameInput.inputProof);
    await strategyContract.submitLastname(lastnameInput.handles[0], lastnameInput.inputProof);
    await strategyContract.submitGender(genderInput.handles[0], genderInput.inputProof);
    await strategyContract.submitNationality(nationalityInput.handles[0], nationalityInput.inputProof);

    // expect(await strategyContract.verify()).to.revertedWith('No id or passport');

    // Submit passport to strategy
    await this.storage.savePassport(new TextEncoder().encode("mock-passport"));

    // Start verification process
    const resp = await strategyContract.verify();
    console.log(resp);

    // User runs FHE script off-chain and submits result
    // Submit result and lock ETH for trial period
  });

  it("should link account to kyc", async function () {});
});
