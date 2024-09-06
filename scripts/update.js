const hre = require("hardhat");

const addresses = {
  DutchAuction: '0x8821e59d29e86C3DF17D989724FEbA5c9aA3a98C',
  EnglishAuction: '0x3a7A53b3586c21df86FceCc60d209706Aa0471ba',
  SealedBidAuctionV1: '0xa9235F5e035d0D622374db11d43e04acea74546D',
  SealedBidAuctionV2: '0x350D35faAB940725C210bf431B8306c3973Bb437',
  VickreyAuction: '0x63724d848CAdE406FF41Bd9A5f05945A399438A4',
  AuctionFactory: '0x38B59C35b6f7e94A0bE04190Af7d744bff0a869D'
};

const test = async () => {
  let adminAccount = (await hre.ethers.getSigners())[0];
  const userAccount = (await hre.ethers.getSigners())[1];
  console.log("Admin address::", adminAccount.address);
  console.log("User address::", userAccount.address);

  const vickreyUtilitiesInstance = await (await hre.ethers.getContractFactory('VickreyUtilities')).connect(adminAccount);
  const vickreyUtilities = await vickreyUtilitiesInstance.deploy();
  await vickreyUtilities.waitForDeployment();
  addresses.VickreyUtilities = vickreyUtilities.target;
  console.log("vickreyUtilities.target::", vickreyUtilities.target);

  const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  const auctionFactoryInstance = auctionFactory.connect(adminAccount);
  var g = await auctionFactoryInstance.setVickreyAdminParams({
    mininumBidDuration: 0,
    minimumRevealDuration: 0,
    VICKREY_UTILITIES: vickreyUtilities.target
  });
  console.log("setVickreyAdminParams gas used:: ", (await g.wait()).gasUsed.toString());

  // const dutchAuctionInstance = await (await hre.ethers.getContractFactory('DutchAuction')).connect(adminAccount);
  // const dutchAuction = await dutchAuctionInstance.deploy();
  // await dutchAuction.waitForDeployment();
  // addresses.DutchAuction = dutchAuction.target;
  // console.log("dutchAuction.target::", addresses.DutchAuction);

  // const englishAuctionInstance = await (await hre.ethers.getContractFactory('EnglishAuction')).connect(adminAccount);
  // const englishAuction = await englishAuctionInstance.deploy();
  // await englishAuction.waitForDeployment();
  // addresses.EnglishAuction = englishAuction.target;
  // console.log("englishAuction.target::", addresses.EnglishAuction);

  // const sealedBidAuctionV1Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV1')).connect(adminAccount);
  // const sealedBidAuctionV1 = await sealedBidAuctionV1Instance.deploy();
  // await sealedBidAuctionV1.waitForDeployment();
  // addresses.SealedBidAuctionV1 = sealedBidAuctionV1.target;
  // console.log("sealedBidAuctionV1.target::", addresses.SealedBidAuctionV1);

  // const sealedBidAuctionV2Instance = await (await hre.ethers.getContractFactory('SealedBidAuctionV2')).connect(adminAccount);
  // const sealedBidAuctionV2 = await sealedBidAuctionV2Instance.deploy();
  // await sealedBidAuctionV2.waitForDeployment();
  // addresses.SealedBidAuctionV2 = sealedBidAuctionV2.target;
  // console.log("sealedBidAuctionV2.target::", addresses.SealedBidAuctionV2);

  // const vickreyAuctionInstance = await (await hre.ethers.getContractFactory('VickreyAuction')).connect(adminAccount);
  // const vickreyAuction = await vickreyAuctionInstance.deploy();
  // await vickreyAuction.waitForDeployment();
  // addresses.VickreyAuction = vickreyAuction.target;
  // console.log("vickreyAuction.target::", addresses.VickreyAuction);

  // const auctionFactory = (await hre.ethers.getContractAt('AuctionFactory', addresses.AuctionFactory));
  // const auctionFactoryInstance = auctionFactory.connect(adminAccount);
  // var g = await auctionFactoryInstance.setAuctionImplementation(2, addresses.DutchAuction);
  // console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  // var g = await auctionFactoryInstance.setAuctionImplementation(0, addresses.EnglishAuction);
  // console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  // var g = await auctionFactoryInstance.setAuctionImplementation(3, addresses.SealedBidAuctionV1);
  // console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  // var g = await auctionFactoryInstance.setAuctionImplementation(4, addresses.SealedBidAuctionV2);
  // console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());
  // var g = await auctionFactoryInstance.setAuctionImplementation(1, addresses.VickreyAuction);
  // console.log("nftCore init gas used:: ", (await g.wait()).gasUsed.toString());

  console.log(addresses);
}
test();
