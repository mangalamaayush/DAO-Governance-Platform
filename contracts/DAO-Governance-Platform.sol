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

    function createProposal(string memory _description) public onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _description, 0, false);
    }

    function vote(uint _proposalId) public {
        require(!hasVoted[msg.sender][_proposalId], "Already voted on this proposal.");
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");

        proposals[_proposalId].voteCount++;
        hasVoted[msg.sender][_proposalId] = true;
    }

    // ✅ New function to execute a proposal
    function executeProposal(uint _proposalId) public onlyOwner {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal ID.");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed.");
        require(proposal.voteCount > 0, "Proposal must have at least one vote.");

        proposal.executed = true;
        // Place proposal execution logic here if needed (e.g., call other contract)
    }
}
