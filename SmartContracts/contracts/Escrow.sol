// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Escrow
 * @dev This contract acts as an escrow service, holding funds until approved by an arbiter and then transferring them to the beneficiary.
 */
contract Escrow is ReentrancyGuard {
    using SafeMath for uint256;

    address public depositor; // Address of the depositor.
    address public beneficiary; // Address of the beneficiary.
    address public arbiter; // Address of the arbiter.
    bool public isApproved; // Flag indicating whether the contract has been approved.
    uint256 public depositedAmount; // Amount of funds deposited in the contract.

    event Approved(uint256 amount);

    /**
     * @dev Constructor function
     * @param _arbiter The address of the arbiter who approves the release of funds.
     * @param _beneficiary The address of the beneficiary who will receive the funds.
     */
    constructor (address _arbiter, address _beneficiary) payable {
        depositor = msg.sender;
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositedAmount = msg.value;
    }

    /**
     * @dev Modifier to restrict a function to only the arbiter.
     */
    modifier onlyArbiter {
        require(msg.sender == arbiter, "You are not an arbiter");
        _;
    }

    /**
     * @dev Function to approve the release of funds to the beneficiary.
     * Only the arbiter can call this function.
     */
    function approve() external onlyArbiter nonReentrant {
        require(!isApproved, "Contract has already been approved");

        (bool sent, ) = beneficiary.call{value: depositedAmount}("");
        require(sent, "Failed to send ether");

        isApproved = true;

        emit Approved(depositedAmount);
    }

    /**
     * @dev Function to withdraw the funds by the beneficiary.
     * The contract must be approved before the withdrawal can be made.
     */
    function withdraw() external nonReentrant {
        require(isApproved, "Contract has not been approved yet");

        uint256 amount = depositedAmount;
        depositedAmount = 0;

        (bool sent, ) = beneficiary.call{value: amount}("");
        require(sent, "Failed to send ether");
    }
}
