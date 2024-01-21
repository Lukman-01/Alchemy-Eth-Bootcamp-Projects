// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title Voting Contract
 * @notice Implements a voting system for proposals, where allowed addresses can create and vote on proposals.
 * @dev The contract uses an enumeration for vote states, a struct for proposals, and tracks allowed addresses for participating in votes.
 */
contract Voting {
    /**
     * @dev Enumeration representing the state of votes.
     */
    enum VoteStates { Absent, Yes, No }

    /**
     * @dev Struct representing a proposal, including target address, proposal data, vote counts, vote states, and execution status.
     */
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        mapping(address => VoteStates) voteStates;
        bool executed;
    }

    /// Array storing all proposals.
    Proposal[] public proposals;

    /// Mapping to track allowed addresses to participate in voting.
    mapping(address => bool) public allowedAddresses;

    /// Event emitted when a proposal is created.
    event ProposalCreated(uint proposalId);

    /// Event emitted when a vote is cast.
    event VoteCast(uint proposalId, address voter);

    /// Event emitted when a proposal is executed.
    event ProposalExecuted(uint proposalId);

    /// Modifier to restrict function access to allowed addresses.
    modifier onlyAllowedAddresses() {
        require(allowedAddresses[msg.sender], "Unauthorized address");
        _;
    }

    /**
     * @dev Constructor to initialize the contract with a list of allowed addresses.
     * @param _allowedAddresses Array of addresses that are allowed to create and vote on proposals.
     */
    constructor(address[] memory _allowedAddresses) {
        for (uint i = 0; i < _allowedAddresses.length; i++) {
            allowedAddresses[_allowedAddresses[i]] = true;
        }
        allowedAddresses[msg.sender] = true;
    }

    /**
     * @dev Creates a new proposal.
     * @param _target Target address for the proposal.
     * @param _data Proposal data.
     */
    function newProposal(address _target, bytes calldata _data) external onlyAllowedAddresses {
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;

        uint proposalId = proposals.length - 1;
        emit ProposalCreated(proposalId);
    }

    /**
     * @dev Casts a vote on a proposal.
     * @param _proposalId The ID of the proposal to vote on.
     * @param _supports Boolean indicating if the vote is in support of the proposal.
     */
    function castVote(uint _proposalId, bool _supports) external onlyAllowedAddresses {
        Proposal storage proposal = proposals[_proposalId];

        // Clear out previous vote
        if (proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if (proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

        // Add new vote
        if (_supports) {
            proposal.yesCount++;
        } else {
            proposal.noCount++;
        }

        // Track whether or not someone has already voted and their vote
        proposal.voteStates[msg.sender] = _supports ? VoteStates.Yes : VoteStates.No;

        emit VoteCast(_proposalId, msg.sender);

        // Execute proposal if the required number of "yes" votes is reached
        if (proposal.yesCount >= 10 && !proposal.executed) {
            (bool success, ) = proposal.target.call(proposal.data);
            require(success, "Execution of proposal failed");
            proposal.executed = true;
            emit ProposalExecuted(_proposalId);
        }
    }
}
