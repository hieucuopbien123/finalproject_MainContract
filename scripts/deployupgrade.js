// npm run deploysepolia
// Nhớ đổi VickreyUtilities dùng đúng network trước

const hre = require("hardhat");
const { upgrades } = require("hardhat");

const addresses = {
  NFTCore: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  NFT1155Core: '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9',
  ERC20MockContract: '0xa513E6E4b8f2a923D98304ec87F64353C4D5C853',
  WETH: '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6',
  Multicall3: '0x8A791620dd6260079BF849Dc5567aDC3F2FdC318',
  VickreyUtilities: '0x610178dA211FEF7D417bC0e6FeD39F05609AD788',
  DutchAuction: '0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e',
  EnglishAuction: '0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0',
  SealedBidAuctionV1: '0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82',
  SealedBidAuctionV2: '0x9A676e781A523b5d0C0e43731313A708CB607508',
  VickreyAuction: '0x0B306BF915C4d645ff596e518fAf3F9669b97016',
  AuctionFactory: '0x68B1D87F95878fE05B998F19b66F4baba5De1aed'
}

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);
  
  const auctionFactoryInstance = await (await hre.ethers.getContractFactory('AuctionFactory')).connect(adminAccount);
  let auctionFactory = await upgrades.upgradeProxy(addresses.AuctionFactory, auctionFactoryInstance);

  console.log(auctionFactory);
}
test();
