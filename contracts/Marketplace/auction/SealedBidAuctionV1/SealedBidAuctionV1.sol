// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import "../../IAuctionFactory.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./SealedBidAuctionV1Base.sol";
import "../NFTStore.sol";

contract SealedBidAuctionV1 is SealedBidAuctionV1Base, ERC1155Holder, NFTStore {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint[] memory _nftIds,
    uint[] memory _nftValues,
    IAuctionFactory.VickreyParams memory params
  ) external initializer {
    SealedBidAuctionV1Base.initialize(operator, _factory, params);
    NFTStore.initialize(_NFTContractAddress, _nftIds, _nftValues);
  }
  function transferNFT(address from, address to) internal override {
    NFTStore.transferNFTX(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(3);
  }
  function revealAuctionFac(address revealer, uint256 actualAmount) internal override {
    IAuctionFactory(factory).revealAuctionInFactory(3, revealer, actualAmount);
  }
  function startRevealFac() internal override {
    IAuctionFactory(factory).startRevealAuctionInFactory(3);
  }
}
