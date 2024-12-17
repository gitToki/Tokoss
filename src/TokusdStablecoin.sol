// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20Burnable, ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";


abstract contract TokusdStablecoin is ERC20Burnable, Ownable{
    error TokusdStablecoin_MustBeMoreThen0();
    error TokusdStablecoin_NotEnoughFunds();
    error TokusdStablecoin_NotZeroAddress();

    constructor() ERC20("TokusdStablecoin", "DSC")  {}
    function  burn(uint256 _amount)  public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0){
            revert TokusdStablecoin_MustBeMoreThen0();
        }
        if (_amount < balance){
            revert TokusdStablecoin_NotEnoughFunds();
        }
        super.burn(_amount);
    }
    function mint(address _to, uint256 _amount) external onlyOwner returns(bool){
        if (_to == address(0)){
            revert TokusdStablecoin_NotZeroAddress();
        }
        if (_amount <= 0){
            revert TokusdStablecoin_MustBeMoreThen0();
        }
        _mint(_to, _amount);
        return true;
    }
}