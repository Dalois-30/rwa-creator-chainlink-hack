// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { DAsset } from "./DAsset.sol";

/// @title RedeemRequest - A contract to handle redemption requests for DAsset tokens
/// @notice This contract allows users to request the redemption of DAsset tokens for a specified redemption coin
/// @dev Uses Chainlink FunctionsClient to send requests and handle responses
/// @author Nguenang Dalois
contract RedeemRequest is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;

    error dTSLA__BelowMinimumRedemption();
    error dTSLA__RedemptionFailed();

    uint32 private constant GAS_LIMIT = 300_000;
    uint64 immutable i_subId;

    address s_functionsRouter;
    string s_redeemAnIncrementSource;
    bytes32 s_donID;
    uint64 s_secretVersion;
    uint8 s_secretSlot;
    address public i_redemptionCoin;
    uint256 private immutable i_redemptionCoinDecimals;

    struct dTslaRequest {
        uint256 amountOfToken;
        address requester;
    }

    mapping(bytes32 => dTslaRequest) private s_requestIdToRequest;
    mapping(address => uint256) private s_userToWithdrawalAmount;

    uint256 public constant MINIMUM_REDEMPTION_COIN_REDEMPTION_AMOUNT = 100e18;
    uint256 public constant PRECISION = 1e18;

    DAsset public s_dAsset;

    /// @notice Constructor to initialize the RedeemRequest contract
    /// @param subId The subscription ID for Chainlink
    /// @param redeemAnIncrementSource The source code for redemption logic
    /// @param functionsRouter The address of the Chainlink Functions router
    /// @param donId The Data Oracle Network ID
    /// @param secretVersion The version of the secrets used
    /// @param secretSlot The slot of the secrets used
    /// @param redemptionCoin The address of the redemption coin
    /// @param dAssetAddress The address of the DAsset contract
    constructor(
        uint64 subId,
        string memory redeemAnIncrementSource,
        address functionsRouter,
        bytes32 donId,
        uint64 secretVersion,
        uint8 secretSlot,
        address redemptionCoin,
        address dAssetAddress
    ) FunctionsClient(functionsRouter) ConfirmedOwner(msg.sender) {
        s_redeemAnIncrementSource = redeemAnIncrementSource;
        s_functionsRouter = functionsRouter;
        s_donID = donId;
        i_subId = subId;
        s_secretVersion = secretVersion;
        s_secretSlot = secretSlot;
        i_redemptionCoin = redemptionCoin;
        i_redemptionCoinDecimals = ERC20(redemptionCoin).decimals();
        s_dAsset = DAsset(dAssetAddress);
    }

    /// @notice Sets the DON ID
    /// @param donId The new DON ID
    function setDonId(bytes32 donId) external onlyOwner {
        s_donID = donId;
    }

    /// @notice Sets the secret version
    /// @param secretVersion The new secret version
    function setSecretVersion(uint64 secretVersion) external onlyOwner {
        s_secretVersion = secretVersion;
    }

    /// @notice Sets the secret slot
    /// @param secretSlot The new secret slot
    function setSecretSlot(uint8 secretSlot) external onlyOwner {
        s_secretSlot = secretSlot;
    }

    /// @notice Sets the DAsset contract address
    /// @param dAsset The new DAsset contract address
    function setDAsset(address dAsset) external onlyOwner {
        s_dAsset = DAsset(dAsset);
    }

    /// @notice Sends a request to redeem DAsset tokens
    /// @param amountdTsla The amount of dTSLA tokens to redeem
    /// @return requestId The ID of the request
    function sendRedeemRequest(uint256 amountdTsla, string memory assetId, address senderAddress)
        external
        returns (bytes32 requestId)
    {
        uint256 amountTslaInUsdc = s_dAsset.getUsdcValueOfUsd(s_dAsset.getUsdValueOfTsla(amountdTsla));
        if (amountTslaInUsdc < MINIMUM_REDEMPTION_COIN_REDEMPTION_AMOUNT) {
            revert dTSLA__BelowMinimumRedemption();
        }
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_redeemAnIncrementSource);
        string[] memory args = new string[](3);
        args[0] = Strings.toHexString(uint256(uint160(senderAddress)), 20);
        args[1] = assetId;
        args[2] = amountTslaInUsdc.toString();
        req.setArgs(args);

        requestId = _sendRequest(req.encodeCBOR(), i_subId, GAS_LIMIT, s_donID);
        s_requestIdToRequest[requestId] = dTslaRequest(amountdTsla, senderAddress);

        s_dAsset.burn(senderAddress, amountdTsla);
    }

    /// @notice Fulfills the redeem request
    /// @param requestId The ID of the request
    /// @param response The response data
    /// @param /* err */ Placeholder for error handling
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory /* err */
    ) internal override {
        uint256 usdcAmount = uint256(bytes32(response))**18;

        if (usdcAmount == 0) {
            uint256 amountOfdTSLABurned = s_requestIdToRequest[requestId].amountOfToken;
            s_dAsset.mint(s_requestIdToRequest[requestId].requester, amountOfdTSLABurned);
            return;
        }

        s_userToWithdrawalAmount[s_requestIdToRequest[requestId].requester] += usdcAmount;
    }

    /// @notice Allows users to withdraw their redeemed amount
    function withdraw(address reciever) external {
        uint256 amountToWithdraw = s_userToWithdrawalAmount[reciever];
        s_userToWithdrawalAmount[reciever] = 0;
        bool succ = ERC20(i_redemptionCoin).transfer(reciever, amountToWithdraw);
        if (!succ) {
            revert dTSLA__RedemptionFailed();
        }
    }

    /// @notice Gets the withdrawal amount for a user
    /// @param user The address of the user
    /// @return The amount available for withdrawal
    function getWithdrawalAmount(address user) public view returns (uint256) {
        return s_userToWithdrawalAmount[user];
    }
}