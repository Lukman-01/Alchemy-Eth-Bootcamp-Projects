 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    address[] public owners;
    uint256 public required;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    /**
     * @dev Modifier to restrict a function to only the contract owners.
     */
    modifier onlyOwners() {
        require(isOwner(msg.sender), "Only owners can call this function.");
        _;
    }

    /**
     * @dev Constructor to initialize the contract with owner addresses and required confirmations.
     * @param _owners The array of owner addresses.
     * @param _required The number of required confirmations.
     */
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "At least one owner address is required.");
        require(_required > 0, "Number of required confirmations must be greater than zero.");
        require(_required <= _owners.length, "Number of required confirmations must be less than or equal to the total number of owner addresses.");

        owners = _owners;
        required = _required;
    }

    /**
     * @dev Get the total number of transactions.
     * @return The number of transactions.
     */
    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }

    /**
     * @dev Submit a new transaction.
     * @param _destination The destination address of the transaction.
     * @param _value The value to be sent with the transaction.
     * @param _data The data to be included in the transaction.
     */
    function submitTransaction(address _destination, uint256 _value, bytes memory _data) public onlyOwners {
        uint256 transactionId = addTransaction(_destination, _value, _data);
        confirmTransaction(transactionId);
    }

    /**
     * @dev Add a new transaction to the list of transactions.
     * @param _destination The destination address of the transaction.
     * @param _value The value to be sent with the transaction.
     * @param _data The data to be included in the transaction.
     * @return The ID of the added transaction.
     */
    function addTransaction(address _destination, uint256 _value, bytes memory _data) internal returns (uint256) {
        Transaction memory transaction = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false
        });

        transactions[transactionCount] = transaction;
        transactionCount++;

        return transactionCount - 1;
    }

    /**
     * @dev Confirm a transaction.
     * @param _id The ID of the transaction to confirm.
     */
    function confirmTransaction(uint256 _id) public onlyOwners {
        require(_id < transactionCount, "Invalid transaction ID.");

        Transaction storage transaction = transactions[_id];
        require(!transaction.executed, "Transaction has already been executed.");
        require(!confirmations[_id][msg.sender], "Transaction already confirmed by this address.");

        confirmations[_id][msg.sender] = true;

        if (isConfirmed(_id)) {
            executeTransaction(_id);
        }
    }

    /**
     * @dev Get the number of confirmations for a transaction.
     * @param _transactionId The ID of the transaction.
     * @return The number of confirmations.
     */
    function getConfirmationsCount(uint256 _transactionId) public view returns (uint256) {
        require(_transactionId < transactionCount, "Invalid transaction ID.");

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[_transactionId][owners[i]]) {
                count++;
            }
        }

        return count;
    }

    /**
     * @dev Check if an address is one of the contract owners.
     * @param _address The address to check.
     * @return True if the address is an owner, false otherwise.
     */
    function isOwner(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Check if a transaction is confirmed.
     * @param _transactionId The ID of the transaction.
     * @return True if the transaction is confirmed, false otherwise.
     */
    function isConfirmed(uint256 _transactionId) public view returns (bool) {
        require(_transactionId < transactionCount, "Invalid transaction ID.");

        uint256 requiredConfirmations = required;
        uint256 confirmationsCount = getConfirmationsCount(_transactionId);

        return confirmationsCount >= requiredConfirmations;
    }

    /**
     * @dev Execute a confirmed transaction.
     * @param _transactionId The ID of the transaction to execute.
     */
    function executeTransaction(uint256 _transactionId) public onlyOwners {
        require(_transactionId < transactionCount, "Invalid transaction ID.");

        Transaction storage transaction = transactions[_transactionId];
        require(!transaction.executed, "Transaction has already been executed.");
        require(isConfirmed(_transactionId), "Transaction is not confirmed.");

        transaction.executed = true;
        (bool success, ) = transaction.destination.call{value: transaction.value}(transaction.data);
        require(success, "Transaction execution failed.");
    }

    /**
     * @dev Fallback function to accept funds at any time.
     */
    receive() external payable {
        // Accept funds at any time
    }
}
