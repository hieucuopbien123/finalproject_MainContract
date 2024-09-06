// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IWETH{
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
  function deposit() external payable;
  function withdraw(uint wad) external;
  
  event Approval(address indexed src, address indexed guy, uint wad);
  event Transfer(address indexed src, address indexed dst, uint wad);
  event Deposit(address indexed dst, uint wad);
  event Withdrawal(address indexed src, uint wad);
}
