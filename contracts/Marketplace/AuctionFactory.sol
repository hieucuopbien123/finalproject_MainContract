// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import { TransferETHLib } from "./utils/TransferETHLib.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IAuctionFactory.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { VickreyAuction } from "./auction/VickreyAuction/VickreyAuction.sol";
import { EnglishAuction } from "./auction/EnglishAuction/EnglishAuction.sol";
import { DutchAuction } from "./auction/DutchAuction/DutchAuction.sol";
import { SealedBidAuctionV1 } from "./auction/SealedBidAuctionV1/SealedBidAuctionV1.sol";
import { SealedBidAuctionV2 } from "./auction/SealedBidAuctionV2/SealedBidAuctionV2.sol";

contract AuctionFactory is OwnableUpgradeable, PausableUpgradeable, IAuctionFactory {
  mapping(AuctionType => address) public auctionImplementation;
  mapping(address => bool) public ongoingAuction;

  VickreyParamsAdmin override public vickreyAdminParams;
  EnglishParamsAdmin override public englishAdminParams;  
  address public WETH_ADDRESS;

  /*╔══════════════════════════════╗
    ║         CONSTRUCTOR          ║
    ╚══════════════════════════════╝*/
  function initialize(
    AuctionType[] memory auctionType,
    address[] memory auctionData, 
    EnglishParamsAdmin memory _englishAdminParams,
    VickreyParamsAdmin memory _vickreyAdminParams,
    address _WETH_ADDRESS
  ) external initializer {
    __Ownable_init();
    __Pausable_init_unchained();
    englishAdminParams = _englishAdminParams;
    vickreyAdminParams = _vickreyAdminParams;
    for(uint i = 0; i < auctionData.length; i++){
      auctionImplementation[auctionType[i]] = auctionData[i];
    }
    WETH_ADDRESS = _WETH_ADDRESS;
  }

  /*╔══════════════════════════════╗
    ║         MAIN LOGIC           ║
    ╚══════════════════════════════╝*/
  function innerCreateAuction(AuctionType, bytes memory) external pure {
    revert NotCallable();
  }

  function createNewAuction(
    AuctionType auctionType, bytes memory auctionData, address operator, 
    address[] memory nftAddresses, uint[] memory nftIds, uint[] memory nftValues
  ) internal returns(address newAuction) {
    newAuction = Clones.clone(auctionImplementation[auctionType]);
    if(auctionType == AuctionType.DUTCHAUCTION) {
      DutchParams memory creatorParams = abi.decode(auctionData, (DutchParams));
      DutchAuction(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.ENGLISHAUCTION) {
      EnglishParams memory creatorParams = abi.decode(auctionData, (EnglishParams));
      EnglishAuction(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.VICKREYAUCTION) {
      VickreyParams memory creatorParams = abi.decode(auctionData, (VickreyParams));
      VickreyAuction(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.SEALEDBIDAUCTIONV1) {
      VickreyParams memory creatorParams = abi.decode(auctionData, (VickreyParams));
      SealedBidAuctionV1(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else if(auctionType == AuctionType.SEALEDBIDAUCTIONV2) {
      SealedBidV2Params memory creatorParams = abi.decode(auctionData, (SealedBidV2Params));
      SealedBidAuctionV2(payable(newAuction)).initialize(
        operator,
        address(this),
        nftAddresses,
        nftIds,
        nftValues,
        creatorParams
      );
    } else {
      revert InvalidAuctionType();
    }
  }
  // ERC721
  function onERC721Received(
    address operator,
    address,
    uint256 _tokenId,
    bytes memory _data
  ) external whenNotPaused returns (bytes4) {    
    {
      bytes4 dataSelector;
      assembly {
        dataSelector := mload(add(_data, 0x20))
      }
      if (dataSelector != AuctionFactory.innerCreateAuction.selector)
        revert InvalidReceiveData();
    }
    assembly {
      mstore(add(_data, 0x04), sub(mload(_data), 0x04))
      _data := add(_data, 0x04)
    }
    (AuctionType auctionType, bytes memory auctionData) = abi.decode(_data, (AuctionType, bytes));
    address[] memory nftAddresses = new address[](1);
    uint[] memory nftIds = new uint[](1);
    uint[] memory nftValues = new uint[](1);
    nftAddresses[0] = msg.sender;
    nftIds[0] = _tokenId;
    nftValues[0] = 0;
    address newAuction = createNewAuction(auctionType, auctionData, operator, nftAddresses, nftIds, nftValues);
    ongoingAuction[newAuction] = true;
    emit AuctionCreated(newAuction, uint256(auctionType));
    IERC721(msg.sender).transferFrom(address(this), newAuction, _tokenId);
    return this.onERC721Received.selector;
  }

  function onERC1155BatchReceived(
    address operator,
    address,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory _data
  ) public whenNotPaused returns (bytes4) {
    {
      bytes4 dataSelector;
      assembly {
        dataSelector := mload(add(_data, 0x20))
      }
      if (dataSelector != AuctionFactory.innerCreateAuction.selector)
        revert InvalidReceiveData();
    }
    assembly {
      mstore(add(_data, 0x04), sub(mload(_data), 0x04))
      _data := add(_data, 0x04)
    }
    (AuctionType auctionType, bytes memory auctionData) = abi.decode(_data, (AuctionType, bytes));
    address[] memory nftAddresses = new address[](1);
    nftAddresses[0] = msg.sender;
    address newAuction = createNewAuction(auctionType, auctionData, operator, nftAddresses, ids, values);
    ongoingAuction[newAuction] = true;
    emit AuctionCreated(newAuction, uint256(auctionType));
    IERC1155(msg.sender).safeBatchTransferFrom(address(this), newAuction, ids, values, "");
    return this.onERC1155BatchReceived.selector;
  }

  function createBulkAuction(
    address[] memory nftAddresses,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory _data,
    bool isOneContract
  ) public whenNotPaused {
    if(isOneContract) {
      (AuctionType auctionType, bytes memory auctionData) = abi.decode(_data, (AuctionType, bytes));
      address newAuction = createNewAuction(auctionType, auctionData, msg.sender, nftAddresses, ids, values);
      ongoingAuction[newAuction] = true;
      emit AuctionCreated(newAuction, uint256(auctionType));
      for(uint i = 0; i < nftAddresses.length; i++) {
        if(values[i] == 0) IERC721(nftAddresses[i]).transferFrom(msg.sender, newAuction, ids[i]);
        else IERC1155(nftAddresses[i]).safeTransferFrom(msg.sender, newAuction, ids[i], values[i], "");
      }
    } else {
      (AuctionType[] memory auctionType, bytes[] memory auctionData) = abi.decode(_data, (AuctionType[], bytes[]));
      for(uint i = 0; i < nftAddresses.length; i++) {
        address[] memory addresses = new address[](1);
        uint256[] memory id = new uint256[](1);
        uint256[] memory value = new uint256[](1);
        addresses[0] = nftAddresses[i];
        id[0] = ids[i];
        value[0] = values[i];
        address newAuction = createNewAuction(auctionType[i], auctionData[i], msg.sender, addresses, id, value);
        ongoingAuction[newAuction] = true;
        emit AuctionCreated(newAuction, uint256(auctionType[i]));
        if(values[i] == 0) IERC721(nftAddresses[i]).transferFrom(msg.sender, newAuction, ids[i]);
        else IERC1155(nftAddresses[i]).safeTransferFrom(msg.sender, newAuction, ids[i], values[i], "");
      }
    }
  }

  /*╔══════════════════════════════╗
    ║        ADMIN FUNCTION        ║
    ╚══════════════════════════════╝*/
  function withdraw(address token, address receiver) external onlyOwner {
    if(token == address(0)) {
      TransferETHLib.transferETH(receiver, address(this).balance, WETH_ADDRESS);
    } else {
      IERC20(token).transfer(receiver, IERC20(token).balanceOf(address(this)));
    }
  }
  bool public isLocked;
  function pause() external onlyOwner {
    isLocked = true;
    _pause();
  }
  function unpauseContract() external onlyOwner {
    isLocked = false;
    _unpause();
  }
  function setAuctionImplementation(AuctionType index, address _auctionAddress) external onlyOwner {
    auctionImplementation[index] = _auctionAddress;
  }
  function setEnglishAdminParams(EnglishParamsAdmin memory _englishAdminParams) external onlyOwner {
    englishAdminParams = _englishAdminParams;
  }
  function setVickreyAdminParams(VickreyParamsAdmin memory _vickreyAdminParams) external onlyOwner {
    vickreyAdminParams = _vickreyAdminParams;
  }

  /*╔═════════════════════════════════════════════╗
    ║        FUNCTION FOR AUCTION CONTRACT        ║
    ╚═════════════════════════════════════════════╝*/
  receive() external payable {}
  function finalizeAuctionInFactory(uint256 auctionType) whenNotPaused external {
    require(ongoingAuction[msg.sender], "NOT_ONGOING_AUCTION");
    ongoingAuction[msg.sender] = false;
    emit AuctionFinalized(msg.sender, auctionType);
  }
  function bidAuctionInFactory(uint256 auctionType, address bidder, uint256 amount) 
  whenNotPaused external {
    require(ongoingAuction[msg.sender], "NOT_ONGOING_AUCTION");
    emit BidAuction(msg.sender, auctionType, bidder, amount);
  }
  function updateAuctionInFactory(uint256 auctionType) whenNotPaused external {
    require(ongoingAuction[msg.sender], "NOT_ONGOING_AUCTION");
    emit UpdateAuction(msg.sender, auctionType);
  }
  function revealAuctionInFactory(uint256 auctionType, address revealer, uint256 actualAmount) 
  whenNotPaused external {
    require(ongoingAuction[msg.sender], "NOT_ONGOING_AUCTION");
    emit RevealAuction(msg.sender, auctionType, revealer, actualAmount);
  }
  function startRevealAuctionInFactory(uint256 auctionType) 
  whenNotPaused external {
    require(ongoingAuction[msg.sender], "NOT_ONGOING_AUCTION");
    emit RevealStarted(msg.sender, auctionType);
  }
}