// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransferETHLib } from "../../utils/TransferETHLib.sol";
import "../../utils/Ownable.sol";
import { IAuctionFactory } from "../../IAuctionFactory.sol";
import "../BaseAuction.sol";

abstract contract SealedBidAuctionV2Base is Ownable, BaseAuction {
  IAuctionFactory factory;
  
  uint256 public basePrice;
  uint256 public revealDuration;
  uint256 public bidEndTime;
  address public paymentToken;
  uint256 public startTime;

  uint256 public bidStep;
  uint256 public revealStep;
  mapping(uint => address) public bidders;

  mapping(address => bytes32) public myPriceHash;
  uint256 public currentBid;
  address public currentBidder;
  bool public isEnded;

  receive() external payable {}
  function updateAuctionFac() internal virtual;

  /*╔═══════════════════════╗
    ║      CONSTRUCTOR      ║
    ╚═══════════════════════╝*/
  function initialize(
    address operator,
    address _factory,
    IAuctionFactory.SealedBidV2Params memory params
  ) internal {
    _setOwner(operator);
    factory = IAuctionFactory(_factory);
    (uint256 mininumBidDuration, uint256 minimumRevealDuration,) = factory.vickreyAdminParams();
    require(params.bidDuration > mininumBidDuration, "Bid duration too small");
    require(params.revealDuration > minimumRevealDuration, "Reveal duration too small");
    basePrice = params.basePrice;
    startTime = block.timestamp + params.waitBeforeStart;
    bidEndTime = startTime + params.bidDuration;
    revealDuration = params.revealDuration;
    paymentToken = params.paymentToken;
  }
  
  function bidAuctionFac(address bidder) internal virtual;
  function revealAuctionFac(address revealer, uint256 actualAmount) internal virtual;

  /*╔══════════════════╗
    ║       BID        ║
    ╚══════════════════╝*/
  function makeOrEditBid(bytes32 priceHash) external {
    require(_msgSender() != owner(), "Auctioneer cannot bid");
    require(block.timestamp <= bidEndTime && block.timestamp >= startTime, "Not bid time");
    require(!isEnded, "Auction has canceled");
    myPriceHash[msg.sender] = priceHash;
    bidders[++bidStep] = msg.sender;
    bidAuctionFac(_msgSender());
  }
  /*╔═════════════════╗
    ║      CANCEL     ║
    ╚═════════════════╝*/
  function cancelAuction() external onlyOwner {
    require(
      bidStep == 0 || (revealStep == 0 && block.timestamp > bidEndTime + revealDuration),
      "Cannot cancel ongoing auction"
    );
    isEnded = true;
    transferNFT(address(this), _msgSender());
    finalizeFac();
  }

  /*╔══════════════════════╗
    ║       REVEEAL        ║
    ╚══════════════════════╝*/

  function claimWin() public nonReentrant {
    require(isEnded == false, "Auction has been claimed");
    isEnded = true;
    require(block.timestamp > bidEndTime + revealDuration, "Not time to claim");
    require(currentBidder != address(0), "No one revealed");
    transferNFT(address(this), currentBidder);
    sendTokenFromThisContractTo(owner(), currentBid);
    finalizeFac();
  }
  function reveal(
    uint256 price,
    bytes32 salt
  ) external payable nonReentrant {
    require(
      isEnded == false && block.timestamp > bidEndTime && (
        revealStep == 0 || ( block.timestamp <= bidEndTime + revealDuration )
      ),
      "Not time to reveal"
    );
    require(
      myPriceHash[msg.sender] == keccak256(abi.encodePacked(price, salt)), 
      "Price hash invalid"
    );
    require(price > currentBid && price > basePrice, "Not highest bidder");
    if(paymentToken == address(0)){
      require(msg.value == price, "Price not match");
    } else {
      IERC20(paymentToken).transferFrom(msg.sender, address(this), price);
    }
    if(currentBidder!= address(0)){
      // Rate 5% fee
      if(revealStep == 1){
        sendTokenFromThisContractTo(currentBidder, currentBid + price / 20);
      } else {
        sendTokenFromThisContractTo(currentBidder, currentBid - currentBid / 20 + price / 20);
      }
    }
    currentBidder = msg.sender;
    currentBid = price;
    revealStep++;
    revealAuctionFac(currentBidder, currentBid);
    if(block.timestamp > bidEndTime + revealDuration && revealStep == 1){
      claimWin();
    }
  }

  function _editAuction(uint256 _newBasePrice, uint256 _newbidDuration, address _paymentToken) internal {
    if(_newbidDuration != 0){
      require(startTime + _newbidDuration > block.timestamp, "New duration too short");
      bidEndTime = startTime + _newbidDuration;
    }
    if(_newBasePrice != 0){
      basePrice = _newBasePrice;
    }
    paymentToken = _paymentToken;
    updateAuctionFac();
  }
  function editAuction(uint256 _newBasePrice, uint256 _newbidDuration, address _paymentToken) external nonReentrant onlyOwner {
    require(
      bidStep == 0 || (revealStep == 0 && block.timestamp > bidEndTime + revealDuration),
      "Cannot edit ongoing auction"
    );
    _editAuction(_newBasePrice, _newbidDuration, _paymentToken);
  }
  
  /*  ╔═════════════════════════╗
      ║        UTILITIES        ║
      ╚═════════════════════════╝ */  
  function getAuctionInfo() external view 
    returns (address, uint256, uint256, uint256, uint256, address, uint256, uint256, uint256, address) 
  {
    return (
      owner(),
      basePrice,
      startTime,
      bidEndTime,
      revealDuration,
      paymentToken,
      bidStep,
      revealStep,
      currentBid,
      currentBidder
    );
  }

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
    if(amount > 0) {
      if(paymentToken == address(0)){
        TransferETHLib.transferETH(to, amount, IAuctionFactory(factory).WETH_ADDRESS());
      } else {
        _payout(address(this), to, amount);
      }
    }
  }
}
