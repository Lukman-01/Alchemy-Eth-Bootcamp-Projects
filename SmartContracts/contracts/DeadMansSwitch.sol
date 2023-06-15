// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Switch {
    uint lastAction; // Stores the timestamp of the last action performed on the contract.
    address recipient; // Stores the address of the eventual recipient of the contract's funds.
    address owner; // Stores the address of the contract owner.

    /**
     * @dev Constructor function
     * @param _recipient The address of the eventual recipient of the contract's funds.
     */
    constructor(address _recipient) payable {
        recipient = _recipient;
        owner = msg.sender;
        lastAction = block.timestamp;
    }

    /**
     * @dev Function to withdraw the contract's balance to the recipient address.
     * The withdrawal can only be performed if at least 52 weeks (1 year) have passed
     * since the last action.
     */
    function withdraw() external {
        require((block.timestamp - lastAction) >= 52 weeks, "Insufficient inactivity period");
        (bool success, ) = recipient.call{ value: address(this).balance }("");
        require(success, "Withdrawal failed");
    }

    /**
     * @dev Function to update the last action timestamp by the contract owner.
     * Only the contract owner can call this function to reset the inactivity period.
     */
    function ping() external {
        require(owner == msg.sender, "Only the owner can ping");
        lastAction = block.timestamp;
    }
}
