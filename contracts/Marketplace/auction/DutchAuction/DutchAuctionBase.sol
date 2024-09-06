//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../IAuctionFactory.sol";
import "../../utils/TransferETHLib.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../../utils/Ownable.sol";
import "../BaseAuction.sol";

abstract contract DutchAuctionBase is Ownable, BaseAuction {
  address factory;
  uint256 public minimumPrice;
  uint256 public startingPrice;
  uint256 public numberOfStep;
  uint256 public stepDuration;
  address public paymentToken;
  uint256 public startingTime;
  bool public isEnded;

  /*╔══════════════════════════════╗
    ║          CONSTRUCTOR         ║
    ╚══════════════════════════════╝*/
  function initialize(
    address operator,
    address _factory,
    IAuctionFactory.DutchParams memory params
  ) internal {
    require(startingPrice >= minimumPrice, "Starting price must be greater than minimum price");
    require(params.numberOfStep > 1, "Invalid number of steps");

    _setOwner(operator);
    factory = _factory;

    minimumPrice = params.minimumPrice;
    startingPrice = params.startingPrice;
    numberOfStep = params.numberOfStep;
    stepDuration = params.stepDuration;
    paymentToken = params.paymentToken;

    startingTime = block.timestamp + params.waitBeforeStart;
  }
  receive() external payable {}
  function bidAuctionFac(address bidder, uint256 amount) internal virtual;

  /*╔══════════════════════════════╗
    ║       CANCEL AUCTION         ║
    ╚══════════════════════════════╝*/
  function cancelAuction() external nonReentrant onlyOwner {
    require(isEnded == false, "Auction ended");
    isEnded = true;
    transferNFT(address(this), _msgSender());
    finalizeFac();
  }

  /*╔════════════════════════╗
    ║          BUY           ║
    ╚════════════════════════╝*/
  function _buy(uint256 _bidPrice) internal {
    require(isEnded == false, "Auction ended");
    uint currentStep = Math.min(((block.timestamp - startingTime) / stepDuration) + 1, numberOfStep);
    uint currentPrice = startingPrice - (currentStep - 1) * ((startingPrice - minimumPrice) / (numberOfStep - 1));
    require(_bidPrice >= currentPrice, "Bid price too low");
    transferNFT(address(this), _msgSender());
    sendTokenFromThisContractTo(owner(), currentPrice);
    uint256 refund = _bidPrice - currentPrice;
    if(refund > 0) {
      sendTokenFromThisContractTo(_msgSender(), refund);
    }
    isEnded = true;
    bidAuctionFac(_msgSender(), _bidPrice);
    finalizeFac();
  }
  function buy(uint256 _bidPrice) external payable nonReentrant {
    require(_msgSender() != owner(), "Auctioneer cannot bid");
    require(block.timestamp > startingTime, "Auction not started yet");
    if(paymentToken == address(0)){
      _buy(msg.value);
    } else {
      _payout(_msgSender(), address(this), _bidPrice);
      _buy(_bidPrice);
    }
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
  function getAuctionInfo() external view 
  returns(uint256, uint256, uint256, uint256, address, uint256, address) {
    return (
      minimumPrice, startingPrice, numberOfStep, stepDuration, paymentToken, startingTime, owner());
  }
}