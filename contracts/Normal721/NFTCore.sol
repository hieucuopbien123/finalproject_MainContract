//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

contract NFTCore is
  ERC721EnumerableUpgradeable,
  OwnableUpgradeable
{
  using StringsUpgradeable for uint256;
  enum NFTType  { S, A, B, C, D, E }
  uint256 _tokenIds;
  mapping(uint256 => uint256) private nftType;
  string private baseURI;

  /*╔══════════════════════════════╗
    ║            EVENTS            ║
    ╚══════════════════════════════╝*/

  event TokenBurned(address owner, uint256 tokenId);
  event BatchTransfer(address from, address to, uint256[] tokenIds);

  /*╔══════════════════════════════╗
    ║           MODIFIER           ║
    ╚══════════════════════════════╝*/

  modifier onlyTokenOwner(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender, "Unauthorized");
    _;
  }

  /*╔══════════════════════════════╗
    ║         CONSTRUCTOR          ║
    ╚══════════════════════════════╝*/

  function initialize(string memory name_, string memory symbol_)
    external
    initializer
  {
    __ERC721_init(name_, symbol_);
    __Ownable_init();
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }
  function setBaseURI(string memory baseURI_) external onlyOwner {
    baseURI = baseURI_;
  }
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    _requireMinted(tokenId);

    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
  }

  /*╔══════════════════════════════╗
    ║          FUNCTIONS           ║
    ╚══════════════════════════════╝*/
  function mintOne(address to)
    external
    onlyOwner
    returns (uint256)
  {
    _tokenIds += 1;
    uint256 id = _tokenIds;
    _mint(to, id);
    nftType[id] = id % 6 + 1;
    return id;
  }

  // Testing only
  function mintBatch(address to, uint quantity)
    external
    onlyOwner
    returns (uint256[] memory)
  {
    uint256[] memory tokenIdsx = new uint256[](quantity);
    for(uint i = 0; i < quantity; i++) {
      _tokenIds += 1;
      uint256 id = _tokenIds;
      _mint(to, id);
      nftType[id] = id % 6 + 1;
      tokenIdsx[i] = id;
    }
    return tokenIdsx;
  }
  
  // Never call burn => This NFT Contract is only used for testing purpose. 
  // When burning, tokensId will return the wrong number of NFT 
  function _burn(uint256 tokenId) internal override {
    super._burn(tokenId);
  }
  function burn(uint256 tokenId) external onlyTokenOwner(tokenId) {
    _burn(tokenId);
    emit TokenBurned(msg.sender, tokenId);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override(ERC721Upgradeable, IERC721Upgradeable) {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual override(ERC721Upgradeable, IERC721Upgradeable) {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    _safeTransfer(from, to, tokenId, _data);
  }

  /*╔══════════════════════════════╗
    ║       GETTER FUNCTION        ║
    ╚══════════════════════════════╝*/
  function getCounter() external view returns (uint256) {
    return _tokenIds;
  }

  function getType(uint256 tokenId) external view returns (uint256) {
    return uint256(nftType[tokenId]);
  }
}
