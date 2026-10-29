// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PausableWithReason} from "./PausableWithReason.sol";

/// @title SHIELDCOIN
/// @notice Fixed-supply ERC-20 source displayed by the project site.
contract Shieldcoin is PausableWithReason {
    string public constant name = "SHIELDCOIN";
    string public constant symbol = "SHD";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1_000_000_000 ether;

    mapping(address account => uint256 balance) public balanceOf;
    mapping(address owner => mapping(address spender => uint256 amount)) public allowance;

    error InvalidSender();
    error InvalidReceiver();
    error InvalidSpender();
    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @param initialHolder Address receiving the complete immutable supply.
    constructor(address initialHolder) PausableWithReason(initialHolder) {
        if (initialHolder == address(0)) revert InvalidReceiver();

        balanceOf[initialHolder] = totalSupply;
        emit Transfer(address(0), initialHolder, totalSupply);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        if (spender == address(0)) revert InvalidSpender();

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 available = allowance[from][msg.sender];

        if (available != type(uint256).max) {
            if (available < value) revert InsufficientAllowance(available, value);

            unchecked {
                allowance[from][msg.sender] = available - value;
            }
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }

        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) private whenNotPaused {
        if (from == address(0)) revert InvalidSender();
        if (to == address(0)) revert InvalidReceiver();

        uint256 available = balanceOf[from];
        if (available < value) revert InsufficientBalance(available, value);

        unchecked {
            balanceOf[from] = available - value;
            balanceOf[to] += value;
        }

        emit Transfer(from, to, value);
    }
}
