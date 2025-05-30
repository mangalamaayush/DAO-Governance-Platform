// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./GovToken.sol";

contract DAOGovernance is Ownable {
    using ECDSA for bytes32;

    GovToken public govToken;
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

    event ProposalCreated(uint id, string description, ProposalType proposalType, uint deadline);
    event Voted(uint proposalId, address voter);
    event Executed(uint proposalId, bool approved);

    constructor(address _govToken) {
        govToken = GovToken(_govToken);
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

        uint256 votes = govToken.getVotes(msg.sender);
        require(votes > 0, "No voting power");

        p.voters[msg.sender] = true;
        p.voteCount += votes;

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

    function getRemainingTime(uint _proposalId) public view returns (uint) {
        Proposal storage p = proposals[_proposalId];
        if (block.timestamp >= p.deadline) {
            return 0;
        } else {
            return p.deadline - block.timestamp;
        }
    }

    // Gasless voting via EIP-712 signature
    function voteBySig(
        uint _proposalId,
        address voter,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        Proposal storage p = proposals[_proposalId];
        require(block.timestamp < p.deadline, "Voting closed");
        require(!p.voters[voter], "Already voted");

        bytes32 structHash = keccak256(abi.encode(_proposalId, voter));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", govToken.DOMAIN_SEPARATOR(), structHash));
        address signer = ECDSA.recover(digest, v, r, s);
        require(signer == voter, "Invalid signature");

        uint256 votes = govToken.getVotes(voter);
        require(votes > 0, "No voting power");

        p.voters[voter] = true;
        p.voteCount += votes;

        emit Voted(_proposalId, voter);
    }
}
