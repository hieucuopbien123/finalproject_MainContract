//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

abstract contract BaseAuction is Initializable, ReentrancyGuard {
  /*╔══════════════════════════════╗
    ║      ABSTRACT METHOD         ║
    ╚══════════════════════════════╝*/
  function transferNFT(address from, address to) internal virtual;
  function finalizeFac() internal virtual;
}