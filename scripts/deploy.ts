import { ethers } from "hardhat";
import {BigNumber} from "ethers";
import { IERC721__factory } from "../typechain-types";

async function main() {
  //reward token deployement
  const [owner] = await ethers.getSigners();
  const RewardToken = await ethers.getContractFactory("rewardToken");
  const rewardToken = await RewardToken.connect(owner).deploy("kenToken", "kent");
  await rewardToken.deployed();
  console.log(`reward Token deployed ${rewardToken.address}`);

//USDC contract interaction
const apeOwner = "0xe785aAfD96E23510A7995E16b49C22D15f219B85";
const USDCCOntractAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const USDCContract = await ethers.getContractAt("IERC721", USDCCOntractAddress);

//stake contract deployment
  const Stake = await ethers.getContractFactory("stake");
  const stake = await Stake.connect(owner).deploy(rewardToken.address);
  await stake.deployed();
  console.log(`stake contract deployed at ${stake.address}`);

//reward token minting
const mintAmount = ethers.utils.parseEther("50")
  await rewardToken.connect(owner).mint(stake.address, mintAmount);
  console.log(`${mintAmount} minted to stake`);

//nft impersonation
const helpers = require("@nomicfoundation/hardhat-network-helpers");
await helpers.impersonateAccount(apeOwner);
const impersonatedSigner = await ethers.getSigner(apeOwner);
await helpers.setBalance(impersonatedSigner.address, 200000000000000000000);

//staking interaction
const approvalAmount = ethers.utils.parseEther("50");
await USDCContract.connect(impersonatedSigner).approve(stake.address, approvalAmount);
await stake.connect(impersonatedSigner).stakingPool(ethers.utils.parseEther("0.00000002"));
console.log(`staking completed`);

await ethers.provider.send("evm_mine", [1809251199]);
const reward = await stake.connect(impersonatedSigner).checkreward();
const wait = await reward.wait();
const rewardAmount = wait.events[0].args[0];
await stake.connect(impersonatedSigner).claimReward(rewardAmount);
console.log(`claim amount is ${rewardAmount}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
