// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WrappedGGC} from "../src/WrappedGGC.sol";

contract CounterScript is Script {
    WrappedGGC public wrappedGGC;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        wrappedGGC = new WrappedGGC();

        vm.stopBroadcast();
    }
}
