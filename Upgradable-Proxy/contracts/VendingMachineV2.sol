// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title Vending Machine Version 2
 * @notice This contract creates an upgradeable vending machine.
 * @dev Inherits from OpenZeppelin's Initializable contract for upgradeability.
 */
contract VendingMachineV2 is Initializable {
    /**
     * @notice Tracks the number of sodas available in the vending machine.
     */
    uint public numSodas;

    /**
     * @notice Address of the vending machine's owner.
     */
    address public owner;

    /**
     * @dev Initializes the vending machine with a specific number of sodas and sets the contract deployer as the owner.
     * @param _numSodas Initial number of sodas stocked in the vending machine.
     */
    function initialize(uint _numSodas) public initializer {
        numSodas = _numSodas;
        owner = msg.sender;
    }

    /**
     * @dev Allows a user to purchase a soda. Requires payment of 1000 wei.
     * @dev Decrements the 'numSodas' state variable upon successful purchase.
     * @notice Purchase a soda for 1000 wei.
     */
    function purchaseSoda() public payable {
        require(msg.value >= 1000 wei, "You must pay 1000 wei for a soda!");
        numSodas--;
        // Challenge: add a mapping to keep track of user soda purchases!
    }

    /**
     * @dev Withdraws all profits from the vending machine. Only callable by the owner.
     * @notice Allows the owner to withdraw all the profits from the vending machine.
     */
    function withdrawProfits() public onlyOwner {
        require(address(this).balance > 0, "Profits must be greater than 0 in order to withdraw!");
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
    }

    /**
     * @dev Sets a new owner for the vending machine.
     * @param _newOwner Address of the new owner.
     */
    function setNewOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    /**
     * @dev Modifier to restrict functions to only the owner of the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
}
