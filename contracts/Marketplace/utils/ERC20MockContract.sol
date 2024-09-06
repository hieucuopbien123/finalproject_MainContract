//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20MockContract is ERC20 {
  constructor(string memory name_, string memory symbol_)
    ERC20(name_, symbol_)
  {
    _mint(msg.sender, 10000000000 * 1e18);
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }
  
  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }
}
