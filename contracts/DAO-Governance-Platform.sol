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
    mapping(uint => address[]) public votersForProposal; // Track voters
    uint public proposalCount;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the DAO owner.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory _description) public onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _description, 0, false);
    }

    function vote(uint _proposalId) public {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        require(!hasVoted[msg.sender][_proposalId], "Already voted on this proposal.");

        proposals[_proposalId].voteCount++;
        hasVoted[msg.sender][_proposalId] = true;
        votersForProposal[_proposalId].push(msg.sender);
    }

    function executeProposal(uint _proposalId) public onlyOwner {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed.");
        require(proposal.voteCount > 0, "Proposal must have at least one vote.");

        proposal.executed = true;
    }

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

    function getVotingStatus(address _voter, uint _proposalId) public view returns (bool) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        return hasVoted[_voter][_proposalId];
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address.");
        owner = newOwner;
    }

    function getTotalVotes() public view returns (uint totalVotes) {
        for (uint i = 1; i <= proposalCount; i++) {
            totalVotes += proposals[i].voteCount;
        }
    }

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

    function getWinningProposal() public view returns (uint winningProposalId, string memory description, uint highestVoteCount) {
        uint highestVotes = 0;
        uint winnerId = 0;

        for (uint i = 1; i <= proposalCount; i++) {
            if (proposals[i].voteCount > highestVotes) {
                highestVotes = proposals[i].voteCount;
                winnerId = proposals[i].id;
            }
        }

        if (winnerId == 0) {
            return (0, "No proposals yet", 0);
        } else {
            Proposal storage winner = proposals[winnerId];
            return (winner.id, winner.description, winner.voteCount);
        }
    }

    // ==================== NEW FUNCTIONS ====================

    /// @notice Check if a proposal has passed (at least 5 votes)
    function hasProposalPassed(uint _proposalId) public view returns (bool) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        return proposal.voteCount >= 5;
    }

    /// @notice Get list of voters who voted for a proposal
    function getVotersForProposal(uint _proposalId) public view returns (address[] memory) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        return votersForProposal[_proposalId];
    }

    /// @notice Delete a proposal (onlyOwner)
    function deleteProposal(uint _proposalId) public onlyOwner {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Cannot delete executed proposal.");

        delete proposals[_proposalId];
        delete votersForProposal[_proposalId];
    }

    /// @notice Update proposal description (onlyOwner, if not executed)
    function updateProposalDescription(uint _proposalId, string memory newDescription) public onlyOwner {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Cannot update an executed proposal.");

        proposal.description = newDescription;
    }
}
