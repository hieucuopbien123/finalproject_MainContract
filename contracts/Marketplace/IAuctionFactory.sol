// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IAuctionFactory {
  /*╔══════════════════════════════╗
    ║      EVENTS AND ERRORS       ║
    ╚══════════════════════════════╝*/
  event AuctionCreated(
    address auction,
    uint256 auctionType
  );
  event AuctionFinalized(
    address auction,
    uint256 auctionType
  );
  event BidAuction(
    address auction,
    uint256 auctionType,
    address bidder,
    uint256 amount
  );
  event RevealStarted(
    address auction,
    uint256 auctionType
  );
  event RevealAuction(
    address auction,
    uint256 auctionType,
    address revealer,
    uint256 actualAmount
  );
  event UpdateAuction(
    address auction,
    uint256 auctionType
  );
  error NotCallable();
  error InvalidReceiveData();
  error InvalidAuctionType();

  /*╔════════════════════════════╗
    ║      ENUM AND STRUCT       ║
    ╚════════════════════════════╝*/
  enum AuctionType {
    ENGLISHAUCTION,
    VICKREYAUCTION,
    DUTCHAUCTION,
    SEALEDBIDAUCTIONV1,
    SEALEDBIDAUCTIONV2,
    OTHERAUCTION1,
    OTHERAUCTION2,
    OTHERAUCTION3,
    OTHERAUCTION4
  }

  struct VickreyParams {
    uint256 basePrice; // default 1 for 1 wei
    uint256 bidDuration; // default 1800 for 30m
    uint256 revealDuration; // default 1800 for 30m
  }
  struct VickreyParamsAdmin {
    uint256 mininumBidDuration; // default 1800 for 30m
    uint256 minimumRevealDuration; // default 1800 for 30m
    address VICKREY_UTILITIES; //!!!!! Trường này nên có thể update bởi developer
  }
  struct EnglishParamsAdmin {
    uint256 minimumRemainingTime; // default 600 for 10p
    uint256 feePercent; // Tiền trả cho người trước đó, nên là 1% = 100
    uint256 bidStepPercent; // Tiền trả hơn người trước đó, nên là 5% = 500
  }
  struct EnglishParams {
    uint256 startingBid; // default 1 for 1 wei
    uint256 bidDuration; 
    address paymentToken;
    uint256 waitBeforeStart;
  }
  struct DutchParams {
    uint256 minimumPrice;
    uint256 startingPrice;
    uint256 numberOfStep;
    uint256 stepDuration;
    address paymentToken;
    uint256 waitBeforeStart;
  }
  struct SealedBidV2Params {
    uint256 basePrice; // default 1 for 1 wei
    uint256 bidDuration; // default 1800 for 30m
    uint256 revealDuration; // default 1800 for 30m
    address paymentToken;
    uint256 waitBeforeStart;
  }

  /*╔═════════════════════╗
    ║      FUNCTIONS      ║
    ╚═════════════════════╝*/
  function finalizeAuctionInFactory(uint256 auctionType) external;
  function bidAuctionInFactory(uint256 auctionType, address bidder, uint256 amount) external;
  function updateAuctionInFactory(uint256 auctionType) external;
  function revealAuctionInFactory(uint256 auctionType, address revealer, uint256 actualAmount) external;
  function startRevealAuctionInFactory(uint256 auctionType) external;
  function isLocked() external view returns (bool);
  function WETH_ADDRESS() external view returns (address);
  function vickreyAdminParams() external view returns(uint256, uint256, address);
  function englishAdminParams() external view returns(uint256, uint256, uint256);
}