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
        address[] voterList;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public voteHistory;

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
        p.voterList.push(msg.sender);
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

    function getRemainingTime(uint _proposalId) public view returns (uint) {
        Proposal storage p = proposals[_proposalId];
        if (block.timestamp >= p.deadline) {
            return 0;
        } else {
            return p.deadline - block.timestamp;
        }
    }

    function getAllProposals()
        public
        view
        returns (
            uint[] memory ids,
            string[] memory descriptions,
            ProposalType[] memory types,
            uint[] memory voteCounts,
            uint[] memory deadlines,
            bool[] memory executedList,
            bool[] memory approvedList
        )
    {
        ids = new uint[](proposalCount);
        descriptions = new string[](proposalCount);
        types = new ProposalType[](proposalCount);
        voteCounts = new uint[](proposalCount);
        deadlines = new uint[](proposalCount);
        executedList = new bool[](proposalCount);
        approvedList = new bool[](proposalCount);

        for (uint i = 1; i <= proposalCount; i++) {
            Proposal storage p = proposals[i];
            uint index = i - 1;
            ids[index] = p.id;
            descriptions[index] = p.description;
            types[index] = p.proposalType;
            voteCounts[index] = p.voteCount;
            deadlines[index] = p.deadline;
            executedList[index] = p.executed;
            approvedList[index] = p.approved;
        }
    }

    function getProposalVoters(uint _proposalId) public view returns (address[] memory) {
        return proposals[_proposalId].voterList;
    }

    function getProposalStats() public view returns (
        uint totalProposals,
        uint totalVotes,
        uint executedProposals,
        uint approvedProposals
    ) {
        totalProposals = proposalCount;
        totalVotes = 0;
        executedProposals = 0;
        approvedProposals = 0;

        for (uint i = 1; i <= proposalCount; i++) {
            Proposal storage p = proposals[i];
            totalVotes += p.voteCount;
            if (p.executed) {
                executedProposals++;
                if (p.approved) {
                    approvedProposals++;
                }
            }
        }
    }

    /// 🆕 Get Active Proposals
    function getActiveProposals() public view returns (uint[] memory activeIds) {
        uint count = 0;

        // First count how many active proposals
        for (uint i = 1; i <= proposalCount; i++) {
            Proposal storage p = proposals[i];
            if (!p.executed && block.timestamp < p.deadline) {
                count++;
            }
        }

        activeIds = new uint[](count);
        uint idx = 0;
        for (uint i = 1; i <= proposalCount; i++) {
            Proposal storage p = proposals[i];
            if (!p.executed && block.timestamp < p.deadline) {
                activeIds[idx] = p.id;
                idx++;
            }
        }
    }
}
