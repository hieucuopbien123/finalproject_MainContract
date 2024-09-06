//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface INFTCore is IERC721Upgradeable {
  function mintOne(address to) external returns (uint256);
  function mintBatch(address to, uint quantity) external returns (uint256[] memory);
  function getCounter() external view returns (uint256);
  function getType(uint256 tokenId) external view returns (uint256);
  function burn(uint256 _tokenId) external;
  function mintOneWithDetail(address to, string memory name, string memory description, string memory uri, string memory otherInfo, int NFTType) external returns (uint256);
}
