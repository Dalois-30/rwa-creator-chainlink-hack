// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import { dAsset } from "../src/dAsset.sol";

contract DeployDTsla is Script {
    string constant mintSourceByBalance = "./functions/sources/getBalance.js";
    string constant decrementSource = "./functions/sources/decrementUserRealBalance.js";
    string constant redeemAnIncrementSource = "./functions/sources/incrementUserRealBalance.js";
    address constant tslaPriceFeed = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
    address constant usdcPriceFeed = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    address constant ethUsdPriceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant functionsRouter = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 constant donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint64 constant subId = 2797;
    address constant redemptionCoin = 0x9c142E4eAC5D20906eD7549EbdA336010ACc6888;
    // address constant ccipRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    // string constant ccipChainSelector = 16_015_286_601_757_825_753;
    uint64 constant secretVersion = 1717268889;
    uint8 constant secretSlot = 0;

    function run() external {

        string memory sourceCode = vm.readFile(mintSourceByBalance);

        // Actually deploy
        vm.startBroadcast();
        deployDTSLA(
            subId,
            sourceCode,
            decrementSource,
            redeemAnIncrementSource,
            functionsRouter,
            donId,
            tslaPriceFeed,
            usdcPriceFeed,
            redemptionCoin,
            secretVersion,
            secretSlot
        );
        vm.stopBroadcast();
    }

    function deployDTSLA(
        uint64 subid,
        string memory mintSrcByBalance,
        string memory decrementSrc,
        string memory redeemAnIncrementSrc,
        address functionRouter,
        bytes32 donid,
        address tslaFeed,
        address usdcFeed,
        address redemptioncoin,
        uint64 secretversion,
        uint8 secretslot
    )
        public
        returns (dAsset)
    {
        dAsset dTsla = new dAsset(
            subid,
            mintSrcByBalance,
            decrementSrc,
            redeemAnIncrementSrc,
            functionRouter,
            donid,
            tslaFeed,
            usdcFeed,
            redemptioncoin,
            secretversion,
            secretslot
        );
        return dTsla;
    }
}
