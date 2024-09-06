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

  const nftCoreInstance = await (await hre.ethers.getContractFactory('NFTCore')).connect(adminAccount);
  const nftCore = await nftCoreInstance.deploy();
  await nftCore.waitForDeployment();
  addresses.NFTCore = nftCore.target;
  console.log("NFTCore.target::", nftCore.target);

  const nftCoreContract = (await hre.ethers.getContractAt('NFTCore', addresses.NFTCore));
  const nftCoreContractInstance = nftCoreContract.connect(adminAccount);
  var g = await nftCoreContractInstance.initialize("TestNamev2", "TestSymbolv2");
  console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  console.log("Initialized with name::", await nftCoreContractInstance.name());
  var g = await nftCoreContractInstance.mintBatch(userAccount.address, 17);  
  console.log("g2 mint batch gas used:: ", (await g.wait()).gasUsed.toString());
  console.log("Balance NFT of user1 after minting::", (await nftCoreContractInstance.balanceOf(userAccount.address)).toString());
  var g = await nftCoreContractInstance.setBaseURI("https://ipfs.io/ipfs/bafybeifwvcrv77f4cjsh4j2kdvxwonlkqbmyjjokwtqrwi4aj4zswbonzq/");  
  console.log("g3 mint batch gas used:: ", (await g.wait()).gasUsed.toString());

  const nft1155CoreInstance = await (await hre.ethers.getContractFactory('NFT1155Core')).connect(adminAccount);
  const nft1155Core = await nft1155CoreInstance.deploy();
  await nft1155Core.waitForDeployment();
  addresses.NFT1155Core = nft1155Core.target;
  console.log("NFT1155Core.target::", nft1155Core.target);

  const nft11155CoreContract = (await hre.ethers.getContractAt('NFT1155Core', addresses.NFT1155Core));
  const nft1155CoreContractInstance = nft11155CoreContract.connect(adminAccount);
  var g = await nft1155CoreContractInstance.initialize("https://arweave.net", "TestSymbol1155V2");
  console.log("nft1155Core init gas used:: ", (await g.wait()).gasUsed.toString());
  console.log("Initialized 1155 with symbol::", await nft1155CoreContractInstance.symbol());
  var g = await nft1155CoreContractInstance.mintBatch(userAccount.address, [1, 2, 3, 4, 5, 6], [50,50,50,50,50,50]);  
  console.log("g2 mint batch 1155 gas used:: ", (await g.wait()).gasUsed.toString());
  console.log("Balance NFT 1155 of user1 id 5 after minting::", (await nft1155CoreContractInstance.balanceOf(userAccount.address, 5)).toString());

  const erc20MockInstance = await (await hre.ethers.getContractFactory('ERC20MockContract')).connect(adminAccount);
  const erc20Mock = await erc20MockInstance.deploy("TestToken", "TEST");
  await erc20Mock.waitForDeployment();
  addresses.ERC20MockContract = erc20Mock.target;
  console.log("erc20Mock.target::", erc20Mock.target);

  const WETHInstance = await (await hre.ethers.getContractFactory('WETH')).connect(adminAccount);
  const WETH = await WETHInstance.deploy();
  await WETH.waitForDeployment();
  addresses.WETH = WETH.target;
  console.log("WETH.target::", WETH.target);

  const multicall3Instance = await (await hre.ethers.getContractFactory('Multicall3')).connect(adminAccount);
  const multicall3 = await multicall3Instance.deploy();
  await multicall3.waitForDeployment();
  addresses.Multicall3 = multicall3.target;
  console.log("multicall3.target::", addresses.Multicall3);

  const vickreyUtilitiesInstance = await (await hre.ethers.getContractFactory('VickreyUtilities')).connect(adminAccount);
  const vickreyUtilities = await vickreyUtilitiesInstance.deploy();
  await vickreyUtilities.waitForDeployment();
  addresses.VickreyUtilities = vickreyUtilities.target;
  console.log("vickreyUtilities.target::", vickreyUtilities.target);

  const dutchAuctionInstance = await (await hre.ethers.getContractFactory('DutchAuction')).connect(adminAccount);
  const dutchAuction = await dutchAuctionInstance.deploy();
  await dutchAuction.waitForDeployment();
  addresses.DutchAuction = dutchAuction.target;
  console.log("dutchAuction.target::", addresses.DutchAuction);

  const englishAuctionInstance = await (await hre.ethers.getContractFactory('EnglishAuction')).connect(adminAccount);
  const englishAuction = await englishAuctionInstance.deploy();
  await englishAuction.waitForDeployment();
  addresses.EnglishAuction = englishAuction.target;
  console.log("englishAuction.target::", addresses.EnglishAuction);

  const sealedBidAuctionV1Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV1')).connect(adminAccount);
  const sealedBidAuctionV1 = await sealedBidAuctionV1Instance.deploy();
  await sealedBidAuctionV1.waitForDeployment();
  addresses.SealedBidAuctionV1 = sealedBidAuctionV1.target;
  console.log("sealedBidAuctionV1.target::", addresses.SealedBidAuctionV1);

  const sealedBidAuctionV2Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV2')).connect(adminAccount);
  const sealedBidAuctionV2 = await sealedBidAuctionV2Instance.deploy();
  await sealedBidAuctionV2.waitForDeployment();
  addresses.SealedBidAuctionV2 = sealedBidAuctionV2.target;
  console.log("sealedBidAuctionV2.target::", addresses.SealedBidAuctionV2);

  const vickreyAuctionInstance = await (await hre.ethers.getContractFactory('VickreyAuction')).connect(adminAccount);
  const vickreyAuction = await vickreyAuctionInstance.deploy();
  await vickreyAuction.waitForDeployment();
  addresses.VickreyAuction = vickreyAuction.target;
  console.log("vickreyAuction.target::", addresses.VickreyAuction);

  const auctionFactoryInstance = await (await hre.ethers.getContractFactory('AuctionFactory')).connect(adminAccount);
  let auctionFactory = await upgrades.deployProxy(auctionFactoryInstance, [
    [0, 1, 2, 3, 4],
    [
      addresses.EnglishAuction,
      addresses.VickreyAuction,
      addresses.DutchAuction,
      addresses.SealedBidAuctionV1,
      addresses.SealedBidAuctionV2
    ],
    {
      feePercent: 100, // 1%
      minimumRemainingTime: 100, // second
      bidStepPercent: 500,
    }, 
    {
      mininumBidDuration: 0,
      minimumRevealDuration: 0,
      VICKREY_UTILITIES: addresses.VickreyUtilities
    },
    addresses.WETH
  ]);

  await auctionFactory.waitForDeployment();
  addresses.AuctionFactory = auctionFactory.target;
  console.log("auctionFactory.target::", addresses.AuctionFactory);

  console.log(addresses);
}
test();
