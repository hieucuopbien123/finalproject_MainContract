//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "../../IAuctionFactory.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./DutchAuctionBase.sol";
import "../NFTStore.sol";

contract DutchAuction is DutchAuctionBase, ERC1155Holder, NFTStore {
  function initialize(
    address operator,
    address _factory,
    address[] memory _NFTContractAddress,
    uint256[] memory _nftIds,
    uint256[] memory _nftValues,
    IAuctionFactory.DutchParams memory params
  ) external initializer {
    DutchAuctionBase.initialize(operator, _factory, params);
    NFTStore.initialize(_NFTContractAddress, _nftIds, _nftValues);
  }

  function transferNFT(address from, address to) internal override {
    NFTStore.transferNFTX(from, to);
  }
  function finalizeFac() internal override {
    IAuctionFactory(factory).finalizeAuctionInFactory(2);
  }
  function bidAuctionFac(address bidder, uint256 amount) internal override {
    IAuctionFactory(factory).bidAuctionInFactory(2, bidder, amount);
  }
}