// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.0 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import {Carbon} from "../src/Carbon.sol";
import "../src/Core.sol";
import {Manager} from "../src/library/Manager.sol";
import {Utils} from "../src/Utils.sol";
import {Loupe} from "../src/library/Loupe.sol";
import "../src/interface/iERC165.sol";
import "../src/interface/iERC173.sol";
import "../src/interface/iManager.sol";
import "../src/interface/iLoupe.sol";

interface iMeta is iERC165, iERC173, iLoupe, iManager {
    function BadFunction() external;
}

contract CarbonTest is Test {
    using Loupe for *;
    using Manager for *;

    Carbon public carbon = new Carbon(address(Manager));
    iMeta public meta = iMeta(address(carbon));
    //Loupe public loupe = new Loupe();

    function setUp() public {
        //
    }
    // [0x7a0ed627, 0xadfca15e, 0x52ef6b2c, 0xcdffacc6]

    function testInterface() public {
        console2.log(address(Loupe));
        assertTrue(meta.supportsInterface(Manager.newContract.selector));
    }

    function testNewContract() public {}

    function testGov() public {
        console2.log(address(Manager));
        assertEq(meta.owner(), address(this));
    }

    function testInvalidFunc() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidFunction.selector, iMeta.BadFunction.selector));
        meta.BadFunction();
    }

    function testDelegateFail() public {
        console2.logBytes4(DelegateCallFailed.selector);
        //(, bytes memory _data) = address(carbon).call(abi.encodeWithSelector(Manager.newContract.selector, address(0x104fBc016F4bb334D775a19E8A6510109AC63E00), [bytes4(0xffffffff)]));
        //assertEq(_data, abi.encodePacked(ContractLocked.selector));
    }
}
