// npm run deploysepolia
// Nhớ đổi VickreyUtilities dùng đúng network trước

const hre = require("hardhat");
const ethers = require("oldethers");
const abiCoder = new ethers.utils.AbiCoder();

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

  const nftCore = await (await hre.ethers.getContractAt('NFTCore', "0x5FbDB2315678afecb367f032d93F642f64180aa3")).connect(userAccount);
  const x = await nftCore.ownerOf(8);
  console.log(x);
  // const g = await nftCore.setApprovalForAll(addresses.AuctionFactory, true);
  // console.log("g3 mint batch gas used:: ", (await g.wait()).gasUsed.toString());

  const test = await (await hre.ethers.getContractAt('EnglishAuction', "0x5E3d0fdE6f793B3115A9E7f5EBC195bbeeD35d6C")).connect(userAccount);
  const y = await test.getAuctionInfo();
  console.log(y);

  const NFT1155Core = await (await hre.ethers.getContractAt('NFT1155Core', "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9")).connect(userAccount);
  // const g1 = await NFT1155Core.setApprovalForAll(addresses.AuctionFactory, true);
  // console.log("g3 mint batch gas used:: ", (await g1.wait()).gasUsed.toString());


  // const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  // auctionFactory.on

  // try{
  //   const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  //   const auctionFactoryInstance = auctionFactory.connect(userAccount);
  //   var gx = await auctionFactoryInstance.createBulkAuction(
  //     ['0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9', '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9', '0x5FbDB2315678afecb367f032d93F642f64180aa3'],
  //     ['2', '1', '8'],
  //     ['1', '2', '0'],
  //     "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000000000000000e1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  //     true
  //   );
  //   console.log("nftCore init gas used:: ", (await gx.wait()).gasUsed.toString());
  // } catch(e) {
  //   console.log(e);
  // }


  // const nftCoreContract = (await hre.ethers.getContractAt('NFTCore', addresses.NFTCore));
  // const nftCoreUser1Contract = nftCoreContract.connect(userAccount);
  // const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  // let englishParams = abiCoder.encode(
  //   ["uint256", "uint256", "uint256", "address"], 
  //   [1, 10*24*60*60, 100, "0x0000000000000000000000000000000000000000"] 
  // );
  // const functionData = auctionFactory.interface.encodeFunctionData(
  //   'innerCreateAuction',
  //   [0, englishParams],
  // );
  // let g = await nftCoreUser1Contract["safeTransferFrom(address,address,uint256,bytes)"](
  //   userAccount.address, 
  //   addresses.AuctionFactory, 
  //   1, 
  //   functionData
  // );
  // console.log("g3 create auction:: ", (await g.wait()).gasUsed.toString());
}
test();
