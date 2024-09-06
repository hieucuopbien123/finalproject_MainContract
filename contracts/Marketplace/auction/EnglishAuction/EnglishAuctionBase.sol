//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../IAuctionFactory.sol";
import "../../utils/TransferETHLib.sol";
import "../../utils/Ownable.sol";
import "../BaseAuction.sol";

abstract contract EnglishAuctionBase is Ownable, BaseAuction {
  address public factory;

  address public paymentToken;
  uint256 public startingBid;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public bidStepPercent;
  uint256 public feePercentage;
  uint256 public minimumRemainingTime;

  address public currentBidder;
  uint256 public currentBid;
  uint256 public bidSteps;
  bool public isCanceled;
  
  /*╔══════════════════════════════╗
    ║          CONSTRUCTOR         ║
    ╚══════════════════════════════╝*/
  function initialize(
    address operator,
    address _factory,
    IAuctionFactory.EnglishParams memory params
  ) internal {
    _setOwner(operator);
    factory = _factory;
    paymentToken = params.paymentToken;
    startingBid = params.startingBid;
    startTime = block.timestamp + params.waitBeforeStart;
    endTime = startTime + params.bidDuration;
    (
      uint256 _minimumRemainingTime,
      uint256 feePercent,
      uint256 bidStepPercent1
    ) = IAuctionFactory(factory).englishAdminParams();
    feePercentage = feePercent;
    bidStepPercent = bidStepPercent1;
    minimumRemainingTime = _minimumRemainingTime;
    require(startingBid > 0 && params.bidDuration > 0 && bidStepPercent > 0, "Invalid params");
  }
  receive() external payable {}

  function updateAuctionFac() internal virtual;
  function bidAuctionFac(address bidder, uint256 amount) internal virtual;

  /*╔══════════════════════════════╗
    ║       CANCEL AUCTION         ║
    ╚══════════════════════════════╝*/
  function cancelAuction() external nonReentrant onlyOwner {
    require(bidSteps == 0, "Cannot cancel ongoing auction");
    isCanceled = true;
    transferNFT(address(this), _msgSender());
    finalizeFac();
  }

  function _editAuction(uint256 _newPrice, uint256 _newDuration, address _paymentToken) internal {
    if(_newDuration != 0){
      require(startTime + _newDuration > block.timestamp, "New duration too short");
      endTime = startTime + _newDuration;
    }
    if(_newPrice!= 0){
      startingBid = _newPrice;
      currentBid = _newPrice;
    }
    paymentToken = _paymentToken;
    updateAuctionFac();
  }
  function editAuction(uint256 _newPrice, uint256 _newDuration, address _paymentToken) external nonReentrant onlyOwner {
    require(bidSteps == 0, "Cannot edit ongoing auction");
    _editAuction(_newPrice, _newDuration, _paymentToken);
  }

  /*╔═════════════════════════════╗
    ║          MAKE BID           ║
    ╚═════════════════════════════╝*/
  function _makeBid(uint256 _bidPrice) internal {
    if (bidSteps == 0) {
      require(_bidPrice >= startingBid, "Bid price too low");
    } else {
      require(
        _bidPrice >= (currentBid * (10000 + bidStepPercent)) / 10000,
        "Bid price too low"
      );
    }
    require(isAuctionOngoing(), "Auction has closed");
    require(_msgSender() != currentBidder, "Already highest bidder");

    if(paymentToken != address(0)){
      _payout(_msgSender(), address(this), _bidPrice);
    }

    uint256 amountToCurrentBidder = 0;
    if (bidSteps > 0) {
      if (bidSteps == 1) {
        amountToCurrentBidder = currentBid + (_bidPrice * feePercentage) / 10000;
      } else {
        amountToCurrentBidder = 
          (currentBid * (10000 - feePercentage)) / 10000 + (_bidPrice * feePercentage) / 10000;
      }
    }
    if(amountToCurrentBidder > 0){
      sendTokenFromThisContractTo(currentBidder, amountToCurrentBidder);
    }

    currentBid = _bidPrice;
    currentBidder = _msgSender();
    bidSteps += 1;

    if (endTime - block.timestamp < minimumRemainingTime) {
      endTime = block.timestamp + minimumRemainingTime;
    }
    bidAuctionFac(currentBidder, _bidPrice);
  }

  function makeBid(uint256 _bidPrice) external payable nonReentrant {
    require(_msgSender() != owner(), "Auctioneer cannot bid");
    require(block.timestamp > startTime, "Auction has not started yet");
    if(paymentToken == address(0)){
      _makeBid(msg.value);
    } else {
      _makeBid(_bidPrice);
    }
  }

  /*  ╔═════════════════════════════╗
      ║      FINALIZE AUCTION       ║
      ╚═════════════════════════════╝*/
  function finalizeAuction() external {
    require(bidSteps != 0, "No one has bid");
    require(!isAuctionOngoing(), "This auction cannot be finalized");

    uint256 hammerPrice = 0;
    if (bidSteps == 1) {
      hammerPrice = currentBid;
    } else {
      hammerPrice = (currentBid * (10000 - feePercentage)) / 10000;
    }
    sendTokenFromThisContractTo(owner(), hammerPrice);

    transferNFT(address(this), currentBidder);
    finalizeFac();
  }

  /*  ╔═════════════════════════╗
      ║        UTILITIES        ║
      ╚═════════════════════════╝ */
  function _payout(
    address _sender,
    address _recipient,
    uint256 _amount
  ) internal {
    if(_sender == address(this)){
      IERC20(paymentToken).transfer(_recipient, _amount);
    } else {
      IERC20(paymentToken).transferFrom(_sender, _recipient, _amount);
    }
  }
  function sendTokenFromThisContractTo(address to, uint256 amount) internal {
    if(paymentToken == address(0)){
      TransferETHLib.transferETH(to, amount, IAuctionFactory(factory).WETH_ADDRESS());
    } else {
      _payout(address(this), to, amount);
    }
  }

  /*╔══════════════════════════════╗
    ║            GETTERS           ║
    ╚══════════════════════════════╝*/
  function isAuctionOngoing() public view returns (bool) {
    return block.timestamp <= endTime && isCanceled == false;
  }
  function getAuctionInfo() external view
  returns (address, uint256, address, uint256, uint256, uint256, uint256, address) 
  {
    return (
      owner(), startingBid, currentBidder, currentBid, startTime, 
      endTime, bidSteps, paymentToken
    );
  }
}