// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DAO {
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        bool executed;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public hasVoted;
    uint public proposalCount;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the DAO owner.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Create a new proposal (onlyOwner)
    function createProposal(string memory _description) public onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _description, 0, false);
    }

    /// @notice Vote on a proposal
    function vote(uint _proposalId) public {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        require(!hasVoted[msg.sender][_proposalId], "Already voted on this proposal.");

        proposals[_proposalId].voteCount++;
        hasVoted[msg.sender][_proposalId] = true;
    }

    /// @notice Execute a proposal (onlyOwner)
    function executeProposal(uint _proposalId) public onlyOwner {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed.");
        require(proposal.voteCount > 0, "Proposal must have at least one vote.");

        proposal.executed = true;
        // Additional execution logic can be added here
    }

    /// @notice Get details of a specific proposal
    function getProposal(uint _proposalId) public view returns (
        uint id,
        string memory description,
        uint voteCount,
        bool executed
    ) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.voteCount,
            proposal.executed
        );
    }

    /// @notice Get all proposals' summary
    function getAllProposals() public view returns (
        uint[] memory ids,
        string[] memory descriptions,
        uint[] memory voteCounts,
        bool[] memory executions
    ) {
        uint count = proposalCount;
        ids = new uint[](count);
        descriptions = new string[](count);
        voteCounts = new uint[](count);
        executions = new bool[](count);

        for (uint i = 0; i < count; i++) {
            Proposal storage proposal = proposals[i + 1];
            ids[i] = proposal.id;
            descriptions[i] = proposal.description;
            voteCounts[i] = proposal.voteCount;
            executions[i] = proposal.executed;
        }

        return (ids, descriptions, voteCounts, executions);
    }

    /// @notice Check if a user has voted on a specific proposal
    function getVotingStatus(address _voter, uint _proposalId) public view returns (bool) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        return hasVoted[_voter][_proposalId];
    }

    /// @notice Change the owner of the DAO (onlyOwner)
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address.");
        owner = newOwner;
    }

    /// @notice Get total number of votes on all proposals
    function getTotalVotes() public view returns (uint totalVotes) {
        for (uint i = 1; i <= proposalCount; i++) {
            totalVotes += proposals[i].voteCount;
        }
    }

    /// @notice Get list of proposals that are not yet executed
    function getPendingProposals() public view returns (uint[] memory pendingIds) {
        uint count;
        for (uint i = 1; i <= proposalCount; i++) {
            if (!proposals[i].executed) {
                count++;
            }
        }

        pendingIds = new uint[](count);
        uint index;
        for (uint i = 1; i <= proposalCount; i++) {
            if (!proposals[i].executed) {
                pendingIds[index] = proposals[i].id;
                index++;
            }
        }
    }
}
