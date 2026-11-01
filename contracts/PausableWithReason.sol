// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice Administrative pause control that preserves a human-readable transfer reason.
abstract contract PausableWithReason {
    address public immutable admin;
    bool public paused;
    string public pauseReason;

    error Unauthorized(address caller);

    event Paused(string reason);
    event Unpaused();

    constructor(address pauseAdmin) {
        admin = pauseAdmin;
    }

    modifier whenNotPaused() {
        if (paused) revert(pauseReason);
        _;
    }

    function pause(string calldata reason) external {
        if (msg.sender != admin) revert Unauthorized(msg.sender);

        paused = true;
        pauseReason = reason;
        emit Paused(reason);
    }

    function unpause() external {
        if (msg.sender != admin) revert Unauthorized(msg.sender);

        paused = false;
        delete pauseReason;
        emit Unpaused();
    }
}
