import { ethers } from "hardhat";

async function main() {
  const Market = await ethers.getContractFactory("Market");
  const market = await Market.deploy(8);

  await market.deployed();

  console.log("Market deployed to:", market.address);

  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();

  await nft.deployed();

  console.log("NFT deployed to:", nft.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
