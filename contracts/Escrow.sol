// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    using SafeERC20 for IERC20;

    enum State {
        // Not started
        NULL,
        // Operation has started and we're waiting approval to release payment
        PENDING_CONFIRMATION,
        // Money has been sent and operation finalized
        FINALIZED
    }

    struct Operation {
        State state;
        address payee;
        uint256 amount;
    }

    IERC20 public token;

    mapping(bytes32 => Operation) public operations;

    event Deposit(bytes32 indexed saleId, address indexed payee, uint256 amount);
    event Sent(bytes32 indexed saleId);

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "Core: invalid erc20");
        token = token_;
    }

    function depositAndInit(bytes32 saleId, uint256 amount) external {
        require(saleId != bytes32(0), "Core: invalid sale ID");
        require(operations[saleId].state == State.NULL, "Core: already started");

        operations[saleId] = Operation(State.PENDING_CONFIRMATION, msg.sender, amount);

        emit Deposit(saleId, msg.sender, amount);

        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function confirmAndSend(bytes32 saleId) external onlyOwner {
        Operation storage op = operations[saleId];

        require(saleId != bytes32(0), "Core: invalid sale ID");
        require(op.state == State.PENDING_CONFIRMATION, "Core: invalid state");

        operations[saleId].state = State.FINALIZED;

        emit Sent(saleId);

        token.safeTransferFrom(address(this), op.payee, op.amount);
    }

    function setERC20(IERC20 token_) external onlyOwner {
        require(address(token_) != address(0), "Core: invalid erc20");
        token = token_;
    }
}
