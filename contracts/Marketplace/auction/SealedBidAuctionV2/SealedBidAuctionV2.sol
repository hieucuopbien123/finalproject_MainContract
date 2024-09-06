// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "../../IAuctionFactory.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./SealedBidAuctionV2Base.sol";
import "../NFTStore.sol";

contract SealedBidAuctionV2 is SealedBidAuctionV2Base, ERC1155Holder, NFTStore {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint[] memory _nftIds,
    uint[] memory _nftValues,
    IAuctionFactory.SealedBidV2Params memory params
  ) external initializer {
    SealedBidAuctionV2Base.initialize(operator, _factory, params);
    NFTStore.initialize(_NFTContractAddress, _nftIds, _nftValues);
  }
  function transferNFT(address from, address to) internal override {
    NFTStore.transferNFTX(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(4);
  }
  function bidAuctionFac(address bidder) internal override {
    IAuctionFactory(factory).bidAuctionInFactory(4, bidder, 0);
  }
  function updateAuctionFac() internal override {
    IAuctionFactory(factory).updateAuctionInFactory(4);
  }
  function revealAuctionFac(address revealer, uint256 actualAmount) internal override {
    IAuctionFactory(factory).revealAuctionInFactory(4, revealer, actualAmount);
  }
}
