// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {DAsset} from "../src/DAsset.sol";
import {console2} from "forge-std/console2.sol";

contract DeployDTsla is Script {

    address constant tslaPriceFeed = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
    address constant usdcPriceFeed = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    
    function run() public {
        vm.startBroadcast();
        DAsset dTsla = new DAsset(tslaPriceFeed, usdcPriceFeed);
        vm.stopBroadcast();

        console2.log(address(dTsla));
    }
}