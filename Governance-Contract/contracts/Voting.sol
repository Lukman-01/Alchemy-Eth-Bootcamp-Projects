// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Voting {
    enum VoteStates { Absent, Yes, No }

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        mapping(address => VoteStates) voteStates;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(address => bool) public allowedAddresses;
    event ProposalCreated(uint proposalId);
    event VoteCast(uint proposalId, address voter);
    event ProposalExecuted(uint proposalId);

    modifier onlyAllowedAddresses() {
        require(allowedAddresses[msg.sender], "Unauthorized address");
        _;
    }

    constructor(address[] memory _allowedAddresses) {
        for (uint i = 0; i < _allowedAddresses.length; i++) {
            allowedAddresses[_allowedAddresses[i]] = true;
        }
        allowedAddresses[msg.sender] = true;
    }

    function newProposal(address _target, bytes calldata _data) external onlyAllowedAddresses {
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;

        uint proposalId = proposals.length - 1;
        emit ProposalCreated(proposalId);
    }

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
