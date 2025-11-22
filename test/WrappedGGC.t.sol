// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WrappedGGC} from "../src/WrappedGGC.sol";

contract WrappedGGCTest is Test {
    WrappedGGC public wrappedGGC;

    function setUp() public {
        wrappedGGC = new WrappedGGC();
    }

    function test_I() public {
    }

    function test_II() public {
    }
}
