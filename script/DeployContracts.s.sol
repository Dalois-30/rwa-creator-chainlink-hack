// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { DAsset } from "../src/DAsset.sol";
import { MintRequest } from "../src/MintRequest.sol";
import { RedeemRequest } from "../src/RedeemRequest.sol";
import { Manager } from "../src/ManagerAsset.sol";
import { MyToken } from "../src/RedemptionToken.sol";
import {console2} from "forge-std/console2.sol";

contract DeployContracts is Script {
    string constant mintSourceByBalance = "./functions/sources/getBalance.js";
    // string constant decrementSource = "./functions/sources/decrementUserRealBalance.js";
    string constant redeemAnIncrementSource = "./functions/sources/decrementUserRealBalance.js";
    address constant tslaPriceFeed = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
    address constant usdcPriceFeed = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    address constant ethUsdPriceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant functionsRouter = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 constant donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint64 constant subId = 2797;
    // address constant redemptionCoin = 0x9c142E4eAC5D20906eD7549EbdA336010ACc6888;
    // address constant ccipRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    // string constant ccipChainSelector = 16_015_286_601_757_825_753;
    uint64 constant secretVersion = 1717268889;
    uint8 constant secretSlot = 0;
    function run() external {
        vm.startBroadcast();

        // Deploy DAsset contract
        DAsset dAsset = new DAsset(tslaPriceFeed, usdcPriceFeed);

        // Deploy Redemption contract
        MyToken redemptionToken = new MyToken();

        // Get sources code
        string memory sourceCode = vm.readFile(mintSourceByBalance);
        string memory redeemSource = vm.readFile(redeemAnIncrementSource);

        // Deploy MintRequest contract
        MintRequest mintRequest = new MintRequest(
            subId,
            sourceCode, 
            functionsRouter,
            donId,
            secretVersion,
            secretSlot,
            address(dAsset)
        );

        // Deploy RedeemRequest contract
        RedeemRequest redeemRequest = new RedeemRequest(
            subId,
            redeemSource, // Replace with the actual redeem an increment source script
            functionsRouter,
            donId,
            secretVersion,
            secretSlot,
            address(redemptionToken),
            address(dAsset)
        );

        // Deploy Manager contract
        Manager manager = new Manager();
        
        // Add the asset to the Manager contract
        manager.addAsset("ASSET", tslaPriceFeed, usdcPriceFeed, address(mintRequest), address(redeemRequest));

        vm.stopBroadcast();

        // Log the deployed contract addresses
        console2.log("DAsset deployed at:", address(dAsset));
        console2.log("Redemption deployed at:", address(redemptionToken));
        console2.log("MintRequest deployed at:", address(mintRequest));
        console2.log("RedeemRequest deployed at:", address(redeemRequest));
        console2.log("Manager deployed at:", address(manager));
    }
}
