// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { DAsset } from "./DAsset.sol";
import { MintRequest } from "./MintRequest.sol";
import { RedeemRequest } from "./RedeemRequest.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

/// @title Manager - A contract to manage DAsset, MintRequest, and RedeemRequest contracts
/// @notice This contract allows the owner to add, remove, and manage assets and their associated contracts
/// @dev Uses ConfirmedOwner for ownership and access control
contract Manager is ConfirmedOwner {
    struct AssetInfo {
        DAsset dAsset;
        MintRequest mintRequest;
        RedeemRequest redeemRequest;
    }

    mapping(string => AssetInfo) private s_assetInfoMapping;

    event AssetAdded(string indexed assetSymb, address indexed dAssetAddress);
    event AssetRemoved(string indexed assetSymb);

    /// @notice Constructor to initialize the Manager contract
    constructor() ConfirmedOwner(msg.sender) {}

    /// @notice Adds a new asset along with its associated contracts
    /// @param assetSymb The symbol of the asset
    /// @param tslaPriceFeed The address of the TSLA price feed
    /// @param usdcPriceFeed The address of the USDC price feed
    /// @param mintRequestAddress The address of the MintRequest contract
    /// @param redeemRequestAddress The address of the RedeemRequest contract
    function addAsset(
        string memory assetSymb,
        address tslaPriceFeed,
        address usdcPriceFeed,
        address mintRequestAddress,
        address redeemRequestAddress
    ) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].dAsset) == address(0), "Asset already exists");

        DAsset newDAsset = new DAsset(tslaPriceFeed, usdcPriceFeed);

        s_assetInfoMapping[assetSymb] = AssetInfo(
            newDAsset,
            MintRequest(mintRequestAddress),
            RedeemRequest(redeemRequestAddress)
        );

        emit AssetAdded(assetSymb, address(newDAsset));
    }

    /// @notice Removes an existing asset along with its associated contracts
    /// @param assetSymb The symbol of the asset
    function removeAsset(string memory assetSymb) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].dAsset) != address(0), "Asset does not exist");

        delete s_assetInfoMapping[assetSymb];

        emit AssetRemoved(assetSymb);
    }

    /// @notice Pauses the DAsset contract of a specified asset
    /// @param assetSymb The symbol of the asset
    function pauseDAsset(string memory assetSymb) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].dAsset) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].dAsset.pause();
    }

    /// @notice Unpauses the DAsset contract of a specified asset
    /// @param assetSymb The symbol of the asset
    function unpauseDAsset(string memory assetSymb) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].dAsset) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].dAsset.unpause();
    }

    /// @notice Gets the information of a specified asset
    /// @param assetSymb The symbol of the asset
    /// @return The AssetInfo struct containing the asset's contracts
    function getAssetInfo(string memory assetSymb) external view returns (AssetInfo memory) {
        return s_assetInfoMapping[assetSymb];
    }

    /// @notice Sets the DON ID for a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param donId The new DON ID
    function setDonId(string memory assetSymb, bytes32 donId) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].mintRequest.setDonId(donId);
        s_assetInfoMapping[assetSymb].redeemRequest.setDonId(donId);
    }

    /// @notice Sets the secret version for a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param secretVersion The new secret version
    function setSecretVersion(string memory assetSymb, uint64 secretVersion) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].mintRequest.setSecretVersion(secretVersion);
        s_assetInfoMapping[assetSymb].redeemRequest.setSecretVersion(secretVersion);
    }

    /// @notice Sets the secret slot for a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param secretSlot The new secret slot
    function setSecretSlot(string memory assetSymb, uint8 secretSlot) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].mintRequest.setSecretSlot(secretSlot);
        s_assetInfoMapping[assetSymb].redeemRequest.setSecretSlot(secretSlot);
    }

    /// @notice Sets the DAsset address for a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param dAssetAddress The new DAsset address
    function setDAssetAddress(string memory assetSymb, address dAssetAddress) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].dAsset) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].mintRequest.setDAsset(dAssetAddress);
        s_assetInfoMapping[assetSymb].redeemRequest.setDAsset(dAssetAddress);
        s_assetInfoMapping[assetSymb].dAsset = DAsset(dAssetAddress);
    }

    /// @notice Sends a mint request for a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param amountOfTokensToMint The amount of tokens to mint
    /// @param assetIdForMint The asset ID for the mint request
    function sendMintRequest(string memory assetSymb, uint256 amountOfTokensToMint, string memory assetIdForMint, address sender)
        external
        onlyOwner
        returns (bytes32)
    {
        return s_assetInfoMapping[assetSymb].mintRequest.sendMintRequest(amountOfTokensToMint, assetIdForMint, sender);
    }

    /// @notice Sends a redeem request for a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param amountdTsla The amount of dTSLA tokens to redeem
    function sendRedeemRequest(string memory assetSymb, uint256 amountdTsla, string memory assetIdForMint, address sender)
        external
        onlyOwner
        returns (bytes32)
    {
        return s_assetInfoMapping[assetSymb].redeemRequest.sendRedeemRequest(amountdTsla, assetIdForMint, sender);
    }

    /// @notice Withdraws the redemption coin for a specified asset
    /// @param assetSymb The symbol of the asset
    function withdraw(string memory assetSymb, address reciever) external onlyOwner {
        s_assetInfoMapping[assetSymb].redeemRequest.withdraw(reciever);
    }

    /// @notice Gets the withdrawal amount for a specified asset and user
    /// @param assetSymb The symbol of the asset
    /// @param user The address of the user
    /// @return The amount available for withdrawal
    function getWithdrawalAmount(string memory assetSymb, address user) external view returns (uint256) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getWithdrawalAmount(user);
    }

    /// @notice Queries the balance of a specified address in the DAsset contract of a specified asset
    /// @param assetSymb The symbol of the asset
    /// @param user The address to query
    /// @return The balance of the specified address
    function balanceOf(string memory assetSymb, address user) external view returns (uint256) {
        return s_assetInfoMapping[assetSymb].dAsset.balanceOf(user);
    }

    // MintRequest getters
    function getMintRequestSubId(string memory assetSymb) external view returns (uint64) {
        return s_assetInfoMapping[assetSymb].mintRequest.getSubId();
    }

    function getMintRequestFunctionsRouter(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].mintRequest.getFunctionsRouter();
    }

    function getMintRequestSource(string memory assetSymb) external view returns (string memory) {
        return s_assetInfoMapping[assetSymb].mintRequest.getMintRequestSource();
    }

    function getMintRequestDonId(string memory assetSymb) external view returns (bytes32) {
        return s_assetInfoMapping[assetSymb].mintRequest.getDonId();
    }

    function getMintRequestSecretVersion(string memory assetSymb) external view returns (uint64) {
        return s_assetInfoMapping[assetSymb].mintRequest.getSecretVersion();
    }

    function getMintRequestSecretSlot(string memory assetSymb) external view returns (uint8) {
        return s_assetInfoMapping[assetSymb].mintRequest.getSecretSlot();
    }

    function getMintRequestDAsset(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].mintRequest.getDAsset();
    }

    // RedeemRequest getters
    function getRedeemRequestSubId(string memory assetSymb) external view returns (uint64) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getSubId();
    }

    function getRedeemRequestFunctionsRouter(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getFunctionsRouter();
    }

    function getRedeemRequestSource(string memory assetSymb) external view returns (string memory) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getRedeemRequestSource();
    }

    function getRedeemRequestDonId(string memory assetSymb) external view returns (bytes32) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getDonId();
    }

    function getRedeemRequestSecretVersion(string memory assetSymb) external view returns (uint64) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getSecretVersion();
    }

    function getRedeemRequestSecretSlot(string memory assetSymb) external view returns (uint8) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getSecretSlot();
    }

    function getRedeemRequestDAsset(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getDAsset();
    }

    function getRedeemRequestRedemptionCoin(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getRedemptionCoin();
    }

    function getRedeemRequestRedemptionCoinDecimals(string memory assetSymb) external view returns (uint256) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getRedemptionCoinDecimals();
    }

    // MintSource and RedeemSource setters
    function setMintRequestSourceAddress(string memory assetSymb, address mintSourceAddress) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].mintRequest = MintRequest(mintSourceAddress);
    }

    function setRedeemRequestSourceAddress(string memory assetSymb, address redeemSourceAddress) external onlyOwner {
        require(address(s_assetInfoMapping[assetSymb].redeemRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetSymb].redeemRequest = RedeemRequest(redeemSourceAddress);
    }

    // MintSource and RedeemSource getters
    function getMintRequestSourceAddress(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].mintRequest.getMintAddress();
    }

    function getRedeemRequestSourceAddress(string memory assetSymb) external view returns (address) {
        return s_assetInfoMapping[assetSymb].redeemRequest.getRedeemAddress();
    }
}
