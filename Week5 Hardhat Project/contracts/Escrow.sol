// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Escrow
 * @notice This contract creates an escrow mechanism between a depositor and a beneficiary, controlled by an arbiter.
 * @dev The contract holds funds sent by the depositor and releases them to the beneficiary upon approval from the arbiter.
 */
contract Escrow {
    /**
     * @notice Address of the arbiter who has the authority to approve fund release.
     */
    address public arbiter;

    /**
     * @notice Address of the beneficiary who receives the funds upon approval.
     */
    address public beneficiary;

    /**
     * @notice Address of the depositor who sends funds to the escrow.
     */
    address public depositor;

    /**
     * @notice Indicates if the funds have been approved for release.
     */
    bool public isApproved;

    /**
     * @dev Initializes the contract by setting the arbiter, beneficiary, and depositor addresses.
     * @param _arbiter The address of the arbiter.
     * @param _beneficiary The address of the beneficiary.
     */
    constructor(address _arbiter, address _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
    }

    /**
     * @dev Emitted when the funds are approved for release.
     * @param balance The balance of Ether released.
     */
    event Approved(uint balance);

    /**
     * @dev Allows the arbiter to approve the release of funds to the beneficiary.
     * @notice Approves the release of funds to the beneficiary.
     */
    function approve() external {
        require(msg.sender == arbiter, "Only the arbiter can approve fund release.");
        uint balance = address(this).balance;
        (bool sent, ) = payable(beneficiary).call{value: balance}("");
        require(sent, "Failed to send Ether");
        emit Approved(balance);
        isApproved = true;
    }
}
