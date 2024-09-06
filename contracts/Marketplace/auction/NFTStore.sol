//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTStore {
  address[] public NFTContractAddress;
  uint256[] public nftIds;
  uint256[] public nftValues;

  function initialize(
    address[] memory _NFTContractAddress,
    uint256[] memory _nftIds,
    uint256[] memory _nftValues
  ) internal {
    NFTContractAddress = _NFTContractAddress;
    nftIds = _nftIds;
    nftValues = _nftValues;
  }

  function transferNFTX(address from, address to) internal {
    if(nftIds.length > NFTContractAddress.length){
      IERC1155(NFTContractAddress[0]).safeBatchTransferFrom(from, to, nftIds, nftValues, "");
    } else {
      for(uint256 i = 0; i < NFTContractAddress.length; i++) {
        if(nftValues[i] == 0) {
          IERC721(NFTContractAddress[i]).safeTransferFrom(from, to, nftIds[i]);
        } else {
          IERC1155(NFTContractAddress[i]).safeTransferFrom(from, to, nftIds[i], nftValues[i], "");
        }
      }
    }
  }
  function getNFTInfo() external view returns(address[] memory, uint256[] memory, uint256[] memory) {
    return (NFTContractAddress, nftIds, nftValues);
  }
}