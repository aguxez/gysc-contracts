// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { Core } from "../contracts/Core.sol";

contract CoreTest is Test {
    Vm internal constant VM = Vm(HEVM_ADDRESS);
    Core internal core;

    address public COLLECTOR = address(this);
    bytes32 public SIGNATURE = bytes32("test_1");
    bytes32 public SECOND_SIGNATURE = bytes32("test_2");
    bytes32 public SALE_ID = bytes32("test_3");

    event ItemIdentity(bytes32 indexed itemIdentityHash);

    function setUp() external {
        core = new Core();
    }

    function testAddIdentity() external {
        VM.expectEmit(true, false, false, false, address(core));
        emit ItemIdentity(keccak256(abi.encodePacked(SALE_ID, uint256(0))));

        core.addIdentity(SALE_ID, 0, COLLECTOR, SIGNATURE);
    }

    function testAddIdentityAddsMoreThanOne() external {
        core.addIdentity(SALE_ID, 0, COLLECTOR, SIGNATURE);
        bytes32 itemHash = core.addIdentity(SALE_ID, 0, HEVM_ADDRESS, SECOND_SIGNATURE);

        (address[] memory collectors, ) = core.getIdentity(itemHash);

        assertEq(collectors.length, 2);
    }

    function testAddIdentityRevertsWithDuplicatedCollector() external {
        core.addIdentity(SALE_ID, 0, COLLECTOR, SIGNATURE);

        VM.expectRevert(bytes("Core: collector exists for item"));
        core.addIdentity(SALE_ID, 0, COLLECTOR, bytes32("something"));
    }

    function testAddIdentityRevertsWithDuplicatedSignature() external {
        core.addIdentity(SALE_ID, 0, COLLECTOR, SIGNATURE);

        VM.expectRevert(bytes("Core: signature exists for item"));
        core.addIdentity(SALE_ID, 0, HEVM_ADDRESS, SIGNATURE);
    }

    function testGetIdentity() external {
        bytes32 itemHash = core.addIdentity(SALE_ID, 0, COLLECTOR, SIGNATURE);

        (address[] memory collectors, bytes32[] memory signatures) = core.getIdentity(itemHash);

        assertEq(collectors.length, 1);
        assertEq(signatures.length, 1);

        assertEq(collectors[0], COLLECTOR);
        assertEq(signatures[0], SIGNATURE);
    }
}
