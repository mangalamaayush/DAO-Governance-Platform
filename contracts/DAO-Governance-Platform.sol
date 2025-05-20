// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DAOGovernance {
    address public owner;
    uint public proposalCount;

    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        uint deadline;
        bool executed;
        mapping(address => bool) voters;
    }

    mapping(uint => Proposal) public proposals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    event ProposalCreated(uint id, string description, uint deadline);
    event Voted(uint proposalId, address voter);
    event Executed(uint proposalId);

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory _description, uint _duration) public onlyOwner {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = _description;
        p.deadline = block.timestamp + _duration;
        emit ProposalCreated(p.id, _description, p.deadline);
    }

    function vote(uint _proposalId) public {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp < p.deadline, "Voting closed");
        require(!p.voters[msg.sender], "Already voted");

        p.voters[msg.sender] = true;
        p.voteCount++;
        emit Voted(_proposalId, msg.sender);
    }

    function executeProposal(uint _proposalId) public onlyOwner {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp >= p.deadline, "Voting not ended");
        require(!p.executed, "Already executed");

        p.executed = true;
        emit Executed(_proposalId);
    }

    function getProposal(uint _proposalId) public view returns (string memory, uint, uint, bool) {
        Proposal storage p = proposals[_proposalId];
        return (p.description, p.voteCount, p.deadline, p.executed);
    }

    function hasVoted(uint _proposalId, address _voter) public view returns (bool) {
        return proposals[_proposalId].voters[_voter];
    }
}
