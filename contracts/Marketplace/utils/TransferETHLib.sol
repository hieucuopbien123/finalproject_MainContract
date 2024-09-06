// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./IWETH.sol";

library TransferETHLib {
  function transferETH(address to, uint256 amount, address WETH_ADDRESS) internal returns(bool success){
    assembly {
      success := call(gas(), to, amount, 0, 0, 0, 0)
    }
    if(!success){
      IWETH(WETH_ADDRESS).deposit{value: amount}();
      IWETH(WETH_ADDRESS).transfer(to, amount);
    }
  }
}