//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFT1155Core is
  ERC1155Upgradeable,
  OwnableUpgradeable
{
  string public symbol;
  function initialize(string memory uri_, string memory symbol_)
    external
    initializer
  {
    symbol = symbol_;
    __ERC1155_init(uri_);
    __Ownable_init();
  }
  function setBaseURI(string memory newBaseURI_) external onlyOwner {
    _setURI(newBaseURI_);
  }
  // Testing only
  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts)
    external
    onlyOwner
  {
    _mintBatch(to, ids, amounts, "");
  }
  function uri(uint256 id) public view virtual override returns (string memory) {
    if(id == 1) {
      return "https://arweave.net/LjyCZiR9D4v8M9mpMKymuyvnXUtTXHftHF2txi3QCGs";
    } else if(id == 2){
      return "https://arweave.net/Tbnh-usk61-Y8lonVFd6SbebnPfUA6wFqMbCBPbyjVM";
    } else if(id == 3){
      return "https://arweave.net/WjLspfljcMRspz_hTvnJbS_b89-6jkTWukSxH4lOmB4";
    } else if(id == 4){
      return "https://arweave.net/ugaqa6rjMlsB1da7-aad4BIA0-fTZTuGWgB3-1MsdmY";
    } else if(id == 5){
      return "https://arweave.net/9hTMrRYhTbY57bCfHzu-2euTq2axTA97XORx-zrx7M4";
    }
    return "https://arweave.net/TaWRESYXMJOEWiFEqg1wUhjyx4ogN1GXxO8jWQzMBQk";
  }
  function testInterface() public view returns(bytes4)
  {
    return type(IERC1155Upgradeable).interfaceId;
  }
  function testInterface2() public view returns(bytes4)
  {
    return type(IERC1155).interfaceId;
  }
}
