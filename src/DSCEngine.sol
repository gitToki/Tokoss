// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TokusdStablecoin} from "./TokusdStablecoin.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DSCEngine is ReentrancyGuard, AggregatorV3Interface {
    error DSCEngine_ZeroFundsTransaction();
    error DSCEngine_TokenAddressAndPriceFeedNotSameLength();
    error DSCGEngin_TokenNotAllowed();
    error DSCEngine_TransferFailled();
    error DSCEngine_BreakHealthFactor(uint256 healthFactor);
    error DSCEngine_MintedFailed();

    uint256 private constant FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_TRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeeds) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;

    address[] private s_collateralTokens;

    TokusdStablecoin private immutable i_dsc;

    event CollateralDeposited(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DSCEngine_ZeroFundsTransaction();
        }
        _;
    }
    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCGEngin_TokenNotAllowed();
        }
        _;
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddress,
        address dscAddress
    ) {
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert DSCEngine_TokenAddressAndPriceFeedNotSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddress[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = TokusdStablecoin(dscAddress);
    }

    function DepositCollateralAndMintDSC() external {}

    function RedeemCollateralForDSC() external {}

    function DepositCollateral(
        address tokencollateralAdress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokencollateralAdress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][
            tokencollateralAdress
        ] += amountCollateral;
        emit CollateralDeposited(
            msg.sender,
            tokencollateralAdress,
            amountCollateral
        );
        bool success = IERC20(tokencollateralAdress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        ); // Following CEI - Check Effect Interraction
        if (!success) {
            revert DSCEngine_TransferFailled();
        }
    }

    function RedeemCollateral(
        address _tokenCollateralAddress,
        uint256 _amountCollateral
    ) external moreThanZero(_amountCollateral) {}

    function burnDSC() external {}

    function mintDSC(
        uint256 amountDSCToMint
    ) external moreThanZero(amountDSCToMint) nonReentrant {

        s_DSCMinted[msg.sender] += amountDSCToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
         bool minted = i_dsc.mint(msg.sender, amountDSCToMint);
         if(!minted){
            revert DSCEngine_MintedFailed();
         }
    }

    function liquidate() external {}

    function getHealthFactor() external view {}

    function _getAccountInformation(
        address user
    )
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueUsd)
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueUsd = getAccountCollateralValue(user);
    }

    function _healthFactor(address user) private view returns (uint256) {
        (
            uint256 totalDscMinted,
            uint256 collateralValueInUsd
        ) = _getAccountInformation(user);
        uint256 collateralAdjustedForTreshold = (collateralValueInUsd *
            LIQUIDATION_TRESHOLD) / LIQUIDATION_PRECISION;
        return ((collateralAdjustedForTreshold * PRECISION) / totalDscMinted);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine_BreakHealthFactor(userHealthFactor);
        }
    }

    function getAccountCollateralValue(
        address user
    ) public view returns (uint256 totalCollateralValueInUsd) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            s_priceFeeds[token]
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return ((uint256(price) * FEED_PRECISION) * amount) / PRECISION;
    }
}
