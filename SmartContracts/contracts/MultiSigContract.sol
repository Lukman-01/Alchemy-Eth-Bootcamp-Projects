// Purpose:
// A multi-signature (multisig) contract is designed to enhance security and enable collective decision-making 
// when managing digital assets or executing transactions on the blockchain. It ensures that multiple authorized 
// parties must provide their approval or signatures before a transaction can be executed, reducing the risk of 
// unauthorized access or fraud.

// Applications:
// 1. Wallet Security: A multisig contract can be used as a more secure form of digital wallet. 
//     Instead of relying on a single private key, multiple owners or authorized parties are required 
//     to sign off on transactions, making it more difficult for hackers to gain control over the assets.
// 2. Fund Management: Organizations or projects that pool funds from multiple contributors can use 
//     a multisig contract to manage those funds. The contract ensures that spending decisions require 
//     consensus among the authorized participants.
// 3. Escrow Services: Multisig contracts can be used as an escrow service where a trusted third party 
//     holds funds in a secure manner until certain conditions are met. The funds are released only 
//     when all parties involved agree to the fulfillment of those conditions.

// Use Cases:
// 1. Decentralized Finance (DeFi): In DeFi applications, multisig contracts are commonly used 
//     to manage and secure funds in decentralized exchanges, lending platforms, or investment protocols. 
//     They provide an added layer of security and reduce the risk of funds being mishandled or stolen.
// 2. Initial Coin Offerings (ICOs): When conducting an ICO or token sale, multisig contracts can be used to 
//     hold the contributed funds until specific milestones or conditions are met. This ensures transparency 
//     and accountability throughout the fundraising process.
// 3. Governance and Voting: Multisig contracts can facilitate collective decision-making in decentralized 
//     organizations or blockchain-based governance systems. Voting on proposals or making significant changes 
//     to the system can require multiple signatures to ensure broad consensus.

// Algorithm:
// 1. Owners: The multisig contract has a list of designated owners or authorized parties 
//     who have the power to approve transactions.
// 2. Transaction Creation: Anyone can propose a transaction by submitting the necessary details, 
//     such as the destination address, amount/value, and any additional data required for the transaction.
// 3. Confirmation: Owners review the proposed transaction and provide their signatures or approvals. 
//     The contract keeps track of the number of confirmations received for each transaction.
// 4. Execution: Once a transaction has received the required number of confirmations, 
//     the contract automatically executes the transaction, transferring the specified funds or 
//     executing the desired operation.
// 5. Security: The multisig contract ensures that transactions can only be executed if they are 
//     confirmed by the required number of owners. This mitigates the risk of unauthorized access 
//     and provides a secure mechanism for managing digital assets.

// In summary, a multisig contract enhances security and facilitates collective decision-making when 
// managing digital assets or executing transactions. It finds applications in wallet security, 
// fund management, escrow services, DeFi, ICOs, and governance systems. The algorithm behind the 
// multisig contract involves multiple owners providing their approvals, with transactions being 
// executed once the required number of confirmations is reached. This helps protect against unauthorized 
// access and ensures secure management of digital assets on the blockchain.



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

    modifier onlyOwners() {
        require(isOwner(msg.sender), "Only owners can call this function.");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "At least one owner address is required.");
        require(_required > 0, "Number of required confirmations must be greater than zero.");
        require(_required <= _owners.length, "Number of required confirmations must be less than or equal to the total number of owner addresses.");

        owners = _owners;
        required = _required;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }

    function submitTransaction(address _destination, uint256 _value, bytes memory _data) public onlyOwners {
        uint256 transactionId = addTransaction(_destination, _value, _data);
        confirmTransaction(transactionId);
    }

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

    function isOwner(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function isConfirmed(uint256 _transactionId) public view returns (bool) {
        require(_transactionId < transactionCount, "Invalid transaction ID.");

        uint256 requiredConfirmations = required;
        uint256 confirmationsCount = getConfirmationsCount(_transactionId);

        return confirmationsCount >= requiredConfirmations;
    }

    function executeTransaction(uint256 _transactionId) public onlyOwners {
        require(_transactionId < transactionCount, "Invalid transaction ID.");

        Transaction storage transaction = transactions[_transactionId];
        require(!transaction.executed, "Transaction has already been executed.");
        require(isConfirmed(_transactionId), "Transaction is not confirmed.");

        transaction.executed = true;
        (bool success, ) = transaction.destination.call{value: transaction.value}(transaction.data);
        require(success, "Transaction execution failed.");
    }

    receive() external payable {
        // Accept funds at any time
    }
}



// WORKFLOW
// 1. Contract Setup:
//    - The multisig contract is deployed on the blockchain with a specified number of owners and 
//     the required number of confirmations needed for transaction execution.
//    - The owners are identified and their addresses are registered in the contract.

// 2. Transaction Proposal:
//    - One of the owners or an authorized party proposes a new transaction by providing the necessary details, 
//     such as the destination address, the amount/value of the transaction, and any additional data required.
//    - The proposed transaction is added to the list of pending transactions in the contract.

// 3. Confirmation Process:
//    - Each owner reviews the proposed transaction and decides whether to approve or reject it based on 
//     their individual judgment or predefined rules.
//    - Owners who approve the transaction provide their digital signatures, indicating their agreement.
//    - The contract keeps track of the number of confirmations received for each transaction.

// 4. Confirmation Threshold Reached:
//    - Once the required number of confirmations is reached (as specified during contract setup), 
//     the transaction is considered confirmed.
//    - At this point, the contract automatically proceeds to execute the transaction.

// 5. Transaction Execution:
//    - The contract executes the confirmed transaction according to the provided details.
//    - For example, if it involves transferring funds, the specified amount is transferred from the 
//     multisig wallet to the designated destination address.
//    - If additional data was provided, such as a function call in the case of interacting with a 
//     smart contract, that action is performed.

// 6. Transaction Completion:
//    - After the transaction is successfully executed, the contract updates the status of the transaction, 
//     marking it as completed or executed.
//    - The completed transaction is recorded in the contract's transaction history.

// 7. Repeat the Process:
//    - The process continues as new transactions are proposed, confirmed, and executed.
//    - Owners review and provide confirmations based on their assessment of each proposed transaction.
//    - The contract ensures that transactions can only be executed when the required number of confirmations is met.