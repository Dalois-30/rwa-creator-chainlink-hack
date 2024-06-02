// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.25;

// import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
// import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
// import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
// import { OracleLib, AggregatorV3Interface } from "./libraries/OracleLib.sol";
// import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
// import { dAsset } from "./dAsset.sol";

// /**
//  * @title dTSLA
//  * @notice This is our contract to make requests to the Alpaca API to mint TSLA-backed dTSLA tokens
//  * @dev This contract is meant to be for educational purposes only
//  */
// contract CheckMint is FunctionsClient, ConfirmedOwner {
//     using FunctionsRequest for FunctionsRequest.Request;
//     using OracleLib for AggregatorV3Interface;
//     using Strings for uint256;
//     using Strings for address;

//     error dTSLA__NotEnoughCollateral();
//     error dTSLA__BelowMinimumRedemption();
//     error dTSLA__RedemptionFailed();

//     // Custom error type
//     error UnexpectedRequestID(bytes32 requestId);

//     enum MintOrRedeem {
//         mint,
//         redeem
//     }

//     struct request {
//         uint256 amountOfToken;
//         address requester;
//         MintOrRedeem mintOrRedeem;
//     }

//     uint32 private constant GAS_LIMIT = 300_000;
//     uint64 immutable i_subId;

//     // Check to get the router address for your supported network
//     // https://docs.chain.link/chainlink-functions/supported-networks
//     address s_functionsRouter;
//     string s_mintSourceByBalance;
//     string s_redeemAnIncrementSource;
//     string s_decrementSource;
//     address s_dAssetAddress;

//     // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
//     bytes32 s_donID;
//     uint256 s_portfolioBalance;
//     uint64 s_secretVersion;
//     uint8 s_secretSlot;

//     mapping(bytes32 requestId => request request) private s_requestIdToRequest;
//     mapping(address user => uint256 amountAvailableForWithdrawal) private s_userToWithdrawalAmount;
//     mapping(address user => uint256 portofoglioBalance) private s_portfolioBalance0fUser;

//     address public i_assetPriceFeed;
//     address public i_usdcUsdFeed;
//     address public i_redemptionCoin;

//     // This hard-coded value isn't great engineering. Please check with your brokerage
//     // and update accordingly
//     // For example, for Alpaca: https://alpaca.markets/support/crypto-wallet-faq
//     uint256 public constant MINIMUM_REDEMPTION_COIN_REDEMPTION_AMOUNT = 100e18;

//     uint256 public constant ADDITIONAL_FEED_PRECISION = 1e10;
//     uint256 public constant PORTFOLIO_PRECISION = 1e18;
//     uint256 public constant COLLATERAL_RATIO = 200; // 200% collateral ratio
//     uint256 public constant COLLATERAL_PRECISION = 100;

//     uint256 private constant TARGET_DECIMALS = 18;
//     uint256 private constant PRECISION = 1e18;
//     uint256 private immutable i_redemptionCoinDecimals;

//     /*//////////////////////////////////////////////////////////////
//                                  EVENTS
//     //////////////////////////////////////////////////////////////*/
//     event Response(bytes32 indexed requestId, uint256 character, bytes response, bytes err);

//     /*//////////////////////////////////////////////////////////////
//                                FUNCTIONS
//     //////////////////////////////////////////////////////////////*/
//     /**
//      * @notice Initializes the contract with the Chainlink router address and sets the contract owner
//      */
//     constructor(
//         uint64 subId,
//         string memory mintSourceByBalance,
//         // string memory decrementSource,
//         // string memory redeemAnIncrementSource,
//         address functionsRouter,
//         address dAssetAddress,
//         bytes32 donId,
//         address assetPriceFeed,
//         address usdcPriceFeed,
//         address redemptionCoin,
//         uint64 secretVersion,
//         uint8 secretSlot
//     )
//         FunctionsClient(functionsRouter)
//         ConfirmedOwner(msg.sender)
//     {
//         s_mintSourceByBalance = mintSourceByBalance;
//         // s_redeemAnIncrementSource = redeemAnIncrementSource;
//         // s_decrementSource = decrementSource;
//         s_functionsRouter = functionsRouter;
//         s_donID = donId;
//         i_assetPriceFeed = assetPriceFeed;
//         i_usdcUsdFeed = usdcPriceFeed;
//         i_subId = subId;
//         i_redemptionCoin = redemptionCoin;
//         s_dAssetAddress = dAssetAddress;
//         // i_redemptionCoinDecimals = ERC20(redemptionCoin).decimals();

//         s_secretVersion = secretVersion;
//         s_secretSlot = secretSlot;
//     }

//     function setSecretVersion(uint64 secretVersion) external onlyOwner {
//         s_secretVersion = secretVersion;
//     }

//     function setSecretSlot(uint8 secretSlot) external onlyOwner {
//         s_secretSlot = secretSlot;
//     }

//     /**
//      * @notice Sends an HTTP request for character information
//      * @dev If you pass 0, that will act just as a way to get an updated portfolio balance
//      * @return requestId The ID of the request
//      */
//     function sendMintRequest(uint256 amountOfTokensToMint, string memory assetId)
//         external
//         returns (bytes32 requestId)
//     {

//         FunctionsRequest.Request memory req;
//         req.initializeRequestForInlineJavaScript(s_mintSourceByBalance); // Initialize the request with JS code
//         req.addDONHostedSecrets(s_secretSlot, s_secretVersion);
//         string[] memory args = new string[](2);
//         args[0] = Strings.toHexString(uint256(uint160(msg.sender)), 20);
//         // args[0] = "0x34F1AF42413326d1255bf02B5402737C10fFbC6a";
//         args[1] = assetId;
//         req.setArgs(args);

//         // Send the request and store the request ID
//         requestId = _sendRequest(req.encodeCBOR(), i_subId, GAS_LIMIT, s_donID);
//         s_requestIdToRequest[requestId] = request(amountOfTokensToMint, msg.sender, MintOrRedeem.mint);
//         return requestId;
//     }

//     /**
//      * @notice Callback function for fulfilling a request
//      * @param requestId The ID of the request to fulfill
//      * @param response The HTTP response data
//      */
//     function fulfillRequest(
//         bytes32 requestId,
//         bytes memory response,
//         bytes memory /* err */
//     )
//         internal
//         override
//     {

//     }

//     function withdraw() external {
//         uint256 amountToWithdraw = s_userToWithdrawalAmount[msg.sender];
//         s_userToWithdrawalAmount[msg.sender] = 0;
//         // Send the user their USDC
//         bool succ = ERC20(i_redemptionCoin).transfer(msg.sender, amountToWithdraw);
//         if (!succ) {
//             revert dTSLA__RedemptionFailed();
//         }
//     }

    

//     function pause() external onlyOwner {
//         _pause();
//     }

//     function unpause() external onlyOwner {
//         _unpause();
//     }

//     /*//////////////////////////////////////////////////////////////
//                                 INTERNAL
//     //////////////////////////////////////////////////////////////*/


//     /*
//      * @notice the callback for the redeem request
//      * At this point, USDC should be in this contract, and we need to update the user
//      * That they can now withdraw their USDC
//      * 
//      * @param requestId - the requestId that was fulfilled
//      * @param response - the response from the request, it'll be the amount of USDC that was sent
//      */
//     function _redeemFulFillRequest(bytes32 requestId, bytes memory response) internal {
//         // This is going to have redemptioncoindecimals decimals
//         uint256 usdcAmount = uint256(bytes32(response));
//         uint256 usdcAmountWad;
//         if (i_redemptionCoinDecimals < 18) {
//             usdcAmountWad = usdcAmount * (10 ** (18 - i_redemptionCoinDecimals));
//         }
//         if (usdcAmount == 0) {
//             // revert dTSLA__RedemptionFailed();
//             // Redemption failed, we need to give them a refund of dTSLA
//             // This is a potential exploit, look at this line carefully!!
//             uint256 amountOfdTSLABurned = s_requestIdToRequest[requestId].amountOfToken;
//             _mint(s_requestIdToRequest[requestId].requester, amountOfdTSLABurned);
//             return;
//         }

//         s_userToWithdrawalAmount[s_requestIdToRequest[requestId].requester] += usdcAmount;
//     }

//     function _getCollateralRatioAdjustedTotalBalance(uint256 amountOfTokensToMint) internal view returns (uint256) {
//         uint256 calculatedNewTotalValue = getCalculatedNewTotalValue(amountOfTokensToMint);
//         return (calculatedNewTotalValue * COLLATERAL_RATIO) / COLLATERAL_PRECISION;
//     }

//     /*//////////////////////////////////////////////////////////////
//                              VIEW AND PURE
//     //////////////////////////////////////////////////////////////*/
//     function getPortfolioBalance() public view returns (uint256) {
//         return s_portfolioBalance;
//     }

//     // TSLA USD has 8 decimal places, so we add an additional 10 decimal places
//     function getTslaPrice() public view returns (uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(i_assetPriceFeed);
//         (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
//         return uint256(price) * ADDITIONAL_FEED_PRECISION;
//     }

//     function getUsdcPrice() public view returns (uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(i_usdcUsdFeed);
//         (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
//         return uint256(price) * ADDITIONAL_FEED_PRECISION;
//     }

//     function getUsdValueOfTsla(uint256 tslaAmount) public view returns (uint256) {
//         return (tslaAmount * getTslaPrice()) / PRECISION;
//     }

//     /* 
//      * Pass the USD amount with 18 decimals (WAD)
//      * Return the redemptionCoin amount with 18 decimals (WAD)
//      * 
//      * @param usdAmount - the amount of USD to convert to USDC in WAD
//      * @return the amount of redemptionCoin with 18 decimals (WAD)
//      */
//     function getUsdcValueOfUsd(uint256 usdAmount) public view returns (uint256) {
//         return (usdAmount * getUsdcPrice()) / PRECISION;
//     }

//     function getTotalUsdValue() public view returns (uint256) {
//         return (totalSupply() * getTslaPrice()) / PRECISION;
//     }

//     function getCalculatedNewTotalValue(uint256 addedNumberOfTsla) public view returns (uint256) {
//         return ((totalSupply() + addedNumberOfTsla) * getTslaPrice()) / PRECISION;
//     }

//     function getRequest(bytes32 requestId) public view returns (request memory) {
//         return s_requestIdToRequest[requestId];
//     }

//     function getWithdrawalAmount(address user) public view returns (uint256) {
//         return s_userToWithdrawalAmount[user];
//     }

//     function getMintSource() public view returns (string memory) {
//         return s_mintSourceByBalance;
//     }
// }
