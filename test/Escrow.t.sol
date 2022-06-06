// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { Escrow } from "../contracts/Escrow.sol";
import { IEscrow, Operation, State } from "../contracts/interfaces/IEscrow.sol";

contract EscrowTest is Test {
    Vm internal constant VM = Vm(HEVM_ADDRESS);

    ERC20Mock internal token;
    Escrow internal escrow;

    bytes32 public constant SALE_ID = bytes32("sale");
    uint256 public constant AMOUNT = 1 ether;

    event Deposit(bytes32 indexed saleId, address indexed payee, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() external {
        token = new ERC20Mock(10 ether);
        escrow = new Escrow(IERC20(address(token)));

        token.approve(address(escrow), 10 ether);
    }

    function testConstrutorRevertsItTokenIs0() external {
        VM.expectRevert(bytes("Escrow: invalid erc20"));
        new Escrow(IERC20(address(0)));
    }

    function testDepositAndInit() external {
        VM.expectEmit(true, true, false, true, address(escrow));
        emit Deposit(SALE_ID, address(this), AMOUNT);

        VM.expectEmit(true, true, false, true, address(token));
        emit Transfer(address(this), address(escrow), AMOUNT);

        escrow.depositAndInit(SALE_ID, AMOUNT);

        Operation memory op = IEscrow(address(escrow)).operations(SALE_ID);

        assertTrue(op.state == State.PENDING_CONFIRMATION);
        assertEq(op.payee, address(this));
        assertEq(op.amount, AMOUNT);
    }

    function testDepositAndInitFailsIfSaleIdIs0() external {
        VM.expectRevert(bytes("Escrow: invalid sale ID"));
        escrow.depositAndInit(bytes32(0), 1);
    }
}

contract ERC20Mock is ERC20 {
    constructor(uint256 supply) ERC20("Token", "TT") {
        _mint(msg.sender, supply);
    }
}
