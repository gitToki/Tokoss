// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokusdStablecoin} from "./TokusdStablecoin.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract DSCEngine is ReentrancyGuard {
    error DSCEngine_ZeroFundsTransaction();
    error DSCEngine_TokenAddressAndPriceFeedNotSameLength();
    error DSCGEngin_TokenNotAllowed();

    mapping(address token => address priceFeeds) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    TokusdStablecoin private immutable i_dsc;

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0){
            revert DSCEngine_ZeroFundsTransaction();
        }
        _;
    }
   modifier isAllowedToken(address token){
        if (s_priceFeeds[token] == address(0)){
            revert DSCGEngin_TokenNotAllowed();
        }
        _;
    }

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddress, address dscAddress){
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert DSCEngine_TokenAddressAndPriceFeedNotSameLength();
        }
        for (uint256 i = 0; i< tokenAddresses.length; i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddress[i];
        }
        i_dsc = TokusdStablecoin(dscAddress);
    }

    function DepositCollateralAndMintDSC() external{}
    function RedeemCollateralForDSC() external{}
        
    function DepositCollateral(address tokencollateralAdress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokencollateralAdress) nonReentrant{
        s_collateralDeposited[msg.sender][tokencollateralAdress] += amountCollateral;
// error to fix        emit s_collateralDeposited(msg.sender, tokencollateralAdress, amountCollateral);
    }

    function RedeemCollateral(address _tokenCollateralAddress, uint256 _amountCollateral) external moreThanZero(_amountCollateral){

    }

    function burnDSC() external{}
    function mintDSC() external{}
    function liquidate() external{}
    function getHealthFactor() external view {}
}