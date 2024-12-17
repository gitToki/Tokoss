// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DSCEngine {
    error DSCEngine_ZeroFundsTransaction();


    modifier moreThanZero(uint256 amount) {
        if (amount <= 0){
            revert DSCEngine_ZeroFundsTransaction;
        }
        _;
    }
 //   modifier isAllowedToken(address token){
        
//    }

    function DepositCollateralAndMintDSC() external{}
    function RedeemCollateralForDSC() external{}
    function DepositCollateralAndMint() external{}

    function RedeemCollateral(address _tokenCollateralAddress, uint256 _amountCollateral) external moreThanZero(_amountCollateral){

    }

    function burnDSC() external{}
    function mintDSC() external{}
    function liquidate() external{}
    function getHealthFactor() external view {}
}