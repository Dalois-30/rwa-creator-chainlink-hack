// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {OracleLib, AggregatorV3Interface} from "./libraries/OracleLib.sol";

/// @title DAsset - A decentralized asset token backed by TSLA and USDC prices
/// @notice This contract allows the minting and burning of a token backed by TSLA and USDC prices
/// @dev Inherits ERC20, Pausable, and ConfirmedOwner contracts
/// @author Nguenang Dalois
contract DAsset is ERC20, Pausable, ConfirmedOwner {
    using OracleLib for AggregatorV3Interface;

    uint256 public constant PORTFOLIO_PRECISION = 1e18;
    uint256 public constant COLLATERAL_RATIO = 200; // 200% collateral ratio
    uint256 public constant COLLATERAL_PRECISION = 100;

    address public i_tslaUsdFeed;
    address public i_usdcUsdFeed;
    uint256 public constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 public constant PRECISION = 1e18;

    /// @notice Constructor to initialize the token with TSLA and USDC price feeds
    /// @param tslaPriceFeed The address of the TSLA price feed
    /// @param usdcPriceFeed The address of the USDC price feed
    constructor(
        address tslaPriceFeed, 
        address usdcPriceFeed
    ) 
        ERC20("Backed Asset", "DAsset") 
        ConfirmedOwner(msg.sender) 
    {
        i_tslaUsdFeed = tslaPriceFeed;
        i_usdcUsdFeed = usdcPriceFeed;
    }

    /// @notice Mints tokens to a specified address
    /// @param to The address to mint the tokens to
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Burns tokens from a specified address
    /// @param from The address to burn the tokens from
    /// @param amount The amount of tokens to burn
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    /// @notice Pauses all token transfers
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses all token transfers
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Gets the current TSLA price from the oracle
    /// @return The TSLA price scaled by ADDITIONAL_FEED_PRECISION
    function getTslaPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_tslaUsdFeed);
        (, int256 price, , , ) = priceFeed.staleCheckLatestRoundData();
        return uint256(price) * ADDITIONAL_FEED_PRECISION;
    }

    /// @notice Gets the current USDC price from the oracle
    /// @return The USDC price scaled by ADDITIONAL_FEED_PRECISION
    function getUsdcPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_usdcUsdFeed);
        (, int256 price, , , ) = priceFeed.staleCheckLatestRoundData();
        return uint256(price) * ADDITIONAL_FEED_PRECISION;
    }

    /// @notice Converts a TSLA amount to its USD value
    /// @param tslaAmount The amount of TSLA tokens
    /// @return The USD value of the given TSLA amount
    function getUsdValueOfTsla(uint256 tslaAmount) public view returns (uint256) {
        return (tslaAmount * getTslaPrice()) / PRECISION;
    }

    /// @notice Converts a USD amount to its USDC value
    /// @param usdAmount The amount of USD
    /// @return The USDC value of the given USD amount
    function getUsdcValueOfUsd(uint256 usdAmount) public view returns (uint256) {
        return (usdAmount * getUsdcPrice()) / PRECISION;
    }

    /// @notice Gets the total USD value of the circulating supply of tokens
    /// @return The total USD value
    function getTotalUsdValue() public view returns (uint256) {
        return (totalSupply() * getTslaPrice()) / PRECISION;
    }

    /// @notice Calculates the new total USD value after adding a certain number of TSLA tokens
    /// @param addedNumberOfTsla The number of additional TSLA tokens
    /// @return The new total USD value
    function getCalculatedNewTotalValue(uint256 addedNumberOfTsla) public view returns (uint256) {
        return ((totalSupply() + addedNumberOfTsla) * getTslaPrice()) / PRECISION;
    }
}
