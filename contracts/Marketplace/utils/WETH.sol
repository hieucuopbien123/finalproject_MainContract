//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

import "./IWETH.sol";

contract WETH is IWETH{
  string public name = "Wrapped Ether";
  string public symbol = "WETH";
  uint8  public decimals = 18;

  mapping(address => uint) public balanceOf;
  mapping(address => mapping(address => uint)) public allowance;

  function deposit() public payable {
    balanceOf[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
  }

  function withdraw(uint wad) public {
    require(balanceOf[msg.sender] >= wad, "Exceed balance");
    balanceOf[msg.sender] -= wad;
    (bool success,) = msg.sender.call{value: wad}("");
    require(success, "FAIL TRANSFER");
    emit Withdrawal(msg.sender, wad);
  }

  function totalSupply() public view returns (uint) {
    return address(this).balance;
  }

  function approve(address guy, uint wad) public returns (bool) {
    allowance[msg.sender][guy] = wad;
    emit Approval(msg.sender, guy, wad);
    return true;
  }

  function transfer(address dst, uint wad) public returns (bool) {
    require(balanceOf[msg.sender] >= wad, "You don't have enough token to transfer WETH");
    balanceOf[msg.sender] -= wad;
    balanceOf[dst] += wad;
    emit Transfer(msg.sender, dst, wad);
    return true;
  }

  function transferFrom(address src, address dst, uint wad) public returns (bool) {
    if(src != msg.sender && allowance[src][msg.sender] >= wad) {
      allowance[src][msg.sender] -= wad;
      return true;
    } 
    if(src == msg.sender){
      balanceOf[src] -= wad;
      balanceOf[dst] += wad;
      return true;
    }
    return false;
  }
}