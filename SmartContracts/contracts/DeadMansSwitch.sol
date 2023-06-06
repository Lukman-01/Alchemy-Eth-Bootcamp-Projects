// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Switch {
	uint lastAction;
	address recipient;
	address owner;

	constructor(address _recipient) payable {
		recipient = _recipient;
		owner = msg.sender;
		lastAction = block.timestamp;
	}

	function withdraw() external {
		require((block.timestamp - lastAction) >= 52 weeks);
		(bool success, ) = recipient.call{ value: address(this).balance }("");
		require(success);
	}

	function ping() external {
		require(owner == msg.sender);
		lastAction = block.timestamp;
	}
}


// - The contract has three state variables:
//   - `lastAction`: stores the timestamp of the last action performed on the contract.
//   - `recipient`: stores the address of the eventual recipient of the contract's funds.
//   - `owner`: stores the address of the contract owner.

// - The constructor function is executed once during contract deployment. It takes an `_recipient` 
//     address as an argument and sets it as the value for the `recipient` variable. 
//     The `msg.sender` address is set as the value for the `owner` variable, representing 
//     the contract deployer. The `block.timestamp` is recorded as the value for the `lastAction` variable.

// - The `withdraw` function is used to transfer the contract's balance to the `recipient` address. 
//     It first checks if at least 52 weeks (1 year) have passed since the last action by comparing 
//     the difference between the current `block.timestamp` and `lastAction`. If the condition is met, 
//     it attempts to transfer the contract's balance to the `recipient` address using the low-level 
//     `call` function. If the transfer is successful, the function completes; otherwise, it reverts.

// - The `ping` function allows the contract owner to reset the `lastAction` timestamp, 
//     thereby restarting the period of inactivity. It verifies that the caller of the 
//     function is the contract owner (`owner`) using the `require` statement. If the condition is met, 
//     the `lastAction` variable is updated with the current `block.timestamp`.

// In summary, the contract enables the recipient address to withdraw the contract's balance 
//     only after a specified period of inactivity (52 weeks) has passed since the last action. 
//     The contract owner can reset the inactivity period by calling the `ping` function.