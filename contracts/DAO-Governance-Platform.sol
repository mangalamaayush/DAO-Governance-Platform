// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DAOGovernance {
    address public owner;
    uint public proposalCount;

    enum ProposalType { GENERAL, FUNDING, TECHNICAL }

    struct Proposal {
        uint id;
        string description;
        ProposalType proposalType;
        uint voteCount;
        uint deadline;
        bool executed;
        bool approved;
        mapping(address => bool) voters;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public voteHistory; // track number of votes per user

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    event ProposalCreated(uint id, string description, ProposalType proposalType, uint deadline);
    event Voted(uint proposalId, address voter);
    event Executed(uint proposalId, bool approved);

    constructor() {
        owner = msg.sender;
    }

    function createProposal(
        string memory _description,
        uint _duration,
        ProposalType _type
    ) public onlyOwner {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.description = _description;
        p.deadline = block.timestamp + _duration;
        p.proposalType = _type;

        emit ProposalCreated(p.id, _description, _type, p.deadline);
    }

    function vote(uint _proposalId) public {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp < p.deadline, "Voting closed");
        require(!p.voters[msg.sender], "Already voted");

        p.voters[msg.sender] = true;
        p.voteCount++;
        voteHistory[msg.sender]++;
        emit Voted(_proposalId, msg.sender);
    }

    function executeProposal(uint _proposalId, uint _quorum) public onlyOwner {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp >= p.deadline, "Voting not ended");
        require(!p.executed, "Already executed");

        p.executed = true;
        p.approved = p.voteCount >= _quorum;

        emit Executed(_proposalId, p.approved);
    }

    function getProposal(uint _proposalId)
        public
        view
        returns (
            string memory description,
            ProposalType proposalType,
            uint voteCount,
            uint deadline,
            bool executed,
            bool approved
        )
    {
        Proposal storage p = proposals[_proposalId];
        return (p.description, p.proposalType, p.voteCount, p.deadline, p.executed, p.approved);
    }

    function hasVoted(uint _proposalId, address _voter) public view returns (bool) {
        return proposals[_proposalId].voters[_voter];
    }

    function getVoteCountByAddress(address _voter) public view returns (uint) {
        return voteHistory[_voter];
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    /// 🔍 New Function: Get Remaining Voting Time for a Proposal
    function getRemainingTime(uint _proposalId) public view returns (uint) {
        Proposal storage p = proposals[_proposalId];
        if (block.timestamp >= p.deadline) {
            return 0;
        } else {
            return p.deadline - block.timestamp;
        }
    }
}
