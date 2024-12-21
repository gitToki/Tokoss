// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {TokusdStablecoin} from "../src/TokusdStablecoin.sol";
import {DSCEngine} from "../src/DSCEngine.sol";

contract DeployDSC is Script{
    function run() external returns(TokusdStablecoin, DSCEngine){
        vm.startBroadcast();
        TokusdStablecoin tokus = new TokusdStablecoin();
        DSCEngine engine = new DSCEngine();
        vm.stopBroadcast();
    }
}