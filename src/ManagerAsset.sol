// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { DAsset } from "./DAsset.sol";
import { MintRequest } from "./MintRequest.sol";
import { RedeemRequest } from "./RedeemRequest.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

/// @title Manager - A contract to manage DAsset, MintRequest, and RedeemRequest contracts
/// @notice This contract allows the owner to add, remove, and manage assets and their associated contracts
/// @dev Uses ConfirmedOwner for ownership and access control
/// @author Nguenang Dalois
contract Manager is ConfirmedOwner {
    struct AssetInfo {
        DAsset dAsset;
        MintRequest mintRequest;
        RedeemRequest redeemRequest;
    }

    mapping(string => AssetInfo) private s_assetInfoMapping;

    event AssetAdded(string indexed assetId, address indexed dAssetAddress);
    event AssetRemoved(string indexed assetId);

    /// @notice Constructor to initialize the Manager contract
    constructor() ConfirmedOwner(msg.sender) {} 

    /// @notice Adds a new asset along with its associated contracts
    /// @param assetId The ID of the asset
    /// @param tslaPriceFeed The address of the TSLA price feed
    /// @param usdcPriceFeed The address of the USDC price feed
    /// @param mintRequestAddress The address of the MintRequest contract
    /// @param redeemRequestAddress The address of the RedeemRequest contract
    function addAsset(
        string memory assetId,
        address tslaPriceFeed,
        address usdcPriceFeed,
        address mintRequestAddress,
        address redeemRequestAddress
    ) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].dAsset) == address(0), "Asset already exists");

        DAsset newDAsset = new DAsset(tslaPriceFeed, usdcPriceFeed);

        s_assetInfoMapping[assetId] = AssetInfo(
            newDAsset,
            MintRequest(mintRequestAddress),
            RedeemRequest(redeemRequestAddress)
        );

        emit AssetAdded(assetId, address(newDAsset));
    }

    /// @notice Removes an existing asset along with its associated contracts
    /// @param assetId The ID of the asset
    function removeAsset(string memory assetId) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].dAsset) != address(0), "Asset does not exist");

        delete s_assetInfoMapping[assetId];

        emit AssetRemoved(assetId);
    }

    /// @notice Pauses the DAsset contract of a specified asset
    /// @param assetId The ID of the asset
    function pauseDAsset(string memory assetId) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].dAsset) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetId].dAsset.pause();
    }

    /// @notice Unpauses the DAsset contract of a specified asset
    /// @param assetId The ID of the asset
    function unpauseDAsset(string memory assetId) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].dAsset) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetId].dAsset.unpause();
    }

    /// @notice Gets the information of a specified asset
    /// @param assetId The ID of the asset
    /// @return The AssetInfo struct containing the asset's contracts
    function getAssetInfo(string memory assetId) external view returns (AssetInfo memory) {
        return s_assetInfoMapping[assetId];
    }

    /// @notice Sets the DON ID for a specified asset
    /// @param assetId The ID of the asset
    /// @param donId The new DON ID
    function setDonId(string memory assetId, bytes32 donId) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetId].mintRequest.setDonId(donId);
        s_assetInfoMapping[assetId].redeemRequest.setDonId(donId);
    }

    /// @notice Sets the secret version for a specified asset
    /// @param assetId The ID of the asset
    /// @param secretVersion The new secret version
    function setSecretVersion(string memory assetId, uint64 secretVersion) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetId].mintRequest.setSecretVersion(secretVersion);
        s_assetInfoMapping[assetId].redeemRequest.setSecretVersion(secretVersion);
    }

    /// @notice Sets the secret slot for a specified asset
    /// @param assetId The ID of the asset
    /// @param secretSlot The new secret slot
    function setSecretSlot(string memory assetId, uint8 secretSlot) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].mintRequest) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetId].mintRequest.setSecretSlot(secretSlot);
        s_assetInfoMapping[assetId].redeemRequest.setSecretSlot(secretSlot);
    }

    /// @notice Sets the DAsset address for a specified asset
    /// @param assetId The ID of the asset
    /// @param dAssetAddress The new DAsset address
    function setDAssetAddress(string memory assetId, address dAssetAddress) external onlyOwner {
        require(address(s_assetInfoMapping[assetId].dAsset) != address(0), "Asset does not exist");

        s_assetInfoMapping[assetId].mintRequest.setDAsset(dAssetAddress);
        s_assetInfoMapping[assetId].redeemRequest.setDAsset(dAssetAddress);
        s_assetInfoMapping[assetId].dAsset = DAsset(dAssetAddress);
    }

    /// @notice Sends a mint request for a specified asset
    /// @param assetId The ID of the asset
    /// @param amountOfTokensToMint The amount of tokens to mint
    /// @param assetIdForMint The asset ID for the mint request
    function sendMintRequest(string memory assetId, uint256 amountOfTokensToMint, string memory assetIdForMint, address sender)
        external
        onlyOwner
        returns (bytes32)
    {
        return s_assetInfoMapping[assetId].mintRequest.sendMintRequest(amountOfTokensToMint, assetIdForMint, sender);
    }

    /// @notice Sends a redeem request for a specified asset
    /// @param assetId The ID of the asset
    /// @param amountdTsla The amount of dTSLA tokens to redeem
    function sendRedeemRequest(string memory assetId, uint256 amountdTsla, address sender)
        external
        onlyOwner
        returns (bytes32)
    {
        return s_assetInfoMapping[assetId].redeemRequest.sendRedeemRequest(amountdTsla, assetId, sender);
    }

    /// @notice Withdraws the redemption coin for a specified asset
    /// @param assetId The ID of the asset
    function withdraw(string memory assetId, address reciever) external onlyOwner {
        s_assetInfoMapping[assetId].redeemRequest.withdraw(reciever);
    }

    /// @notice Gets the withdrawal amount for a specified asset and user
    /// @param assetId The ID of the asset
    /// @param user The address of the user
    /// @return The amount available for withdrawal
    function getWithdrawalAmount(string memory assetId, address user) external view returns (uint256) {
        return s_assetInfoMapping[assetId].redeemRequest.getWithdrawalAmount(user);
    }

    /// @notice Queries the balance of a specified address in the DAsset contract of a specified asset
    /// @param assetId The ID of the asset
    /// @param user The address to query
    /// @return The balance of the specified address
    function balanceOf(string memory assetId, address user) external view returns (uint256) {
        return s_assetInfoMapping[assetId].dAsset.balanceOf(user);
    }
}
