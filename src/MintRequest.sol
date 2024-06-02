// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { DAsset } from "./DAsset.sol";

/// @title MintRequest - A contract to handle mint requests for DAsset tokens
/// @notice This contract allows users to request the minting of DAsset tokens based on certain conditions
/// @dev Uses Chainlink FunctionsClient to send requests and handle responses
/// @author Nguenang Dalois
contract MintRequest is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;
    using Strings for address;

    uint32 private constant GAS_LIMIT = 300_000;
    uint64 immutable i_subId;

    address s_functionsRouter;
    string s_mintSourceByBalance;
    bytes32 s_donID;
    uint256 s_portfolioBalance;
    uint64 s_secretVersion;
    uint8 s_secretSlot;

    struct dTslaRequest {
        uint256 amountOfToken;
        address requester;
    }

    mapping(bytes32 => dTslaRequest) private s_requestIdToRequest;

    DAsset public s_dAsset;

    /// @notice Constructor to initialize the MintRequest contract
    /// @param subId The subscription ID for Chainlink
    /// @param mintSourceByBalance The source code for minting logic
    /// @param functionsRouter The address of the Chainlink Functions router
    /// @param donId The Data Oracle Network ID
    /// @param secretVersion The version of the secrets used
    /// @param secretSlot The slot of the secrets used
    /// @param dAssetAddress The address of the DAsset contract
    constructor(
        uint64 subId,
        string memory mintSourceByBalance,
        address functionsRouter,
        bytes32 donId,
        uint64 secretVersion,
        uint8 secretSlot,
        address dAssetAddress
    ) FunctionsClient(functionsRouter) ConfirmedOwner(msg.sender) {
        s_mintSourceByBalance = mintSourceByBalance;
        s_functionsRouter = functionsRouter;
        s_donID = donId;
        i_subId = subId;
        s_secretVersion = secretVersion;
        s_secretSlot = secretSlot;
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

    /// @notice Sends a request to mint DAsset tokens
    /// @param amountOfTokensToMint The amount of tokens to mint
    /// @param assetId The asset ID
    /// @return requestId The ID of the request
    function sendMintRequest(uint256 amountOfTokensToMint, string memory assetId, address sender)
        external
        returns (bytes32 requestId)
    {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_mintSourceByBalance);
        req.addDONHostedSecrets(s_secretSlot, s_secretVersion);
        string[] memory args = new string[](2);
        args[0] = Strings.toHexString(uint256(uint160(sender)), 20);
        args[1] = assetId;
        req.setArgs(args);

        requestId = _sendRequest(req.encodeCBOR(), i_subId, GAS_LIMIT, s_donID);
        s_requestIdToRequest[requestId] = dTslaRequest(amountOfTokensToMint, sender);
        return requestId;
    }

    /// @notice Fulfills the mint request
    /// @param requestId The ID of the request
    /// @param response The response data
    /// @param /* err */ Placeholder for error handling
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory /* err */
    ) internal override {
        s_portfolioBalance = uint256(bytes32(response));
        uint256 amountOfTokensToMint = s_requestIdToRequest[requestId].amountOfToken;

        // if (_getCollateralRatioAdjustedTotalBalance(amountOfTokensToMint) < s_portfolioBalance) {
        s_dAsset.mint(s_requestIdToRequest[requestId].requester, amountOfTokensToMint);
        // }
    }

    /// @notice Calculates the new total balance adjusted by the collateral ratio
    /// @param amountOfTokensToMint The amount of tokens to mint
    /// @return The adjusted total balance
    function _getCollateralRatioAdjustedTotalBalance(uint256 amountOfTokensToMint)
        internal
        view
        returns (uint256)
    {
        uint256 calculatedNewTotalValue = s_dAsset.getCalculatedNewTotalValue(amountOfTokensToMint);
        return (calculatedNewTotalValue * s_dAsset.COLLATERAL_RATIO()) / s_dAsset.COLLATERAL_PRECISION();
    }

    /// @notice Gets the subscription ID
    /// @return subId The subscription ID
    function getSubId() external view returns (uint64) {
        return i_subId;
    }

    /// @notice Gets the functions router address
    /// @return functionsRouter The functions router address
    function getFunctionsRouter() external view returns (address) {
        return s_functionsRouter;
    }

    /// @notice Gets the mint source by balance
    /// @return mintRequestSourceCode The mint source by balance
    function getMintRequestSource() external view returns (string memory) {
        return s_mintSourceByBalance;
    }

    /// @notice Gets the DON ID
    /// @return donId The DON ID
    function getDonId() external view returns (bytes32) {
        return s_donID;
    }

    /// @notice Gets the portfolio balance
    /// @return portfolioBalance The portfolio balance
    function getPortfolioBalance() external view returns (uint256) {
        return s_portfolioBalance;
    }

    /// @notice Gets the secret version
    /// @return secretVersion The secret version
    function getSecretVersion() external view returns (uint64) {
        return s_secretVersion;
    }

    /// @notice Gets the secret slot
    /// @return secretSlot The secret slot
    function getSecretSlot() external view returns (uint8) {
        return s_secretSlot;
    }

    /// @notice Gets the DAsset contract address
    /// @return dAsset The DAsset contract address
    function getDAsset() external view returns (address) {
        return address(s_dAsset);
    }

    /// @notice Gets the mint request details by request ID
    /// @param requestId The ID of the request
    /// @return amountOfToken The amount of tokens
    /// @return requester The requester address
    function getRequestDetails(bytes32 requestId)
        external
        view
        returns (uint256 amountOfToken, address requester)
    {
        dTslaRequest memory request = s_requestIdToRequest[requestId];
        return (request.amountOfToken, request.requester);
    }

    /// @notice Gets the mint request address
    /// @return address the current contract address
    function getMintAddress() external view returns (address) {
        return address(this);
    }
}
