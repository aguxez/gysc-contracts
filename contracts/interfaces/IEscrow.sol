// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

interface IEscrow {
    function operations(bytes32 saleId) external view returns (Operation memory);
}
