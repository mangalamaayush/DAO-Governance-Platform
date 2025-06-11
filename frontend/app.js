const contractAddress = "0xd05bDCbA66cCF6F759B9dA07c246E83F8F8b5946";

const abi = [
  {
    "inputs": [
      { "internalType": "address", "name": "_govToken", "type": "address" }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "uint256", "name": "id", "type": "uint256" },
      { "indexed": false, "internalType": "string", "name": "description", "type": "string" },
      { "indexed": false, "internalType": "uint8", "name": "proposalType", "type": "uint8" },
      { "indexed": false, "internalType": "uint256", "name": "deadline", "type": "uint256" }
    ],
    "name": "ProposalCreated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "uint256", "name": "proposalId", "type": "uint256" },
      { "indexed": false, "internalType": "address", "name": "voter", "type": "address" }
    ],
    "name": "Voted",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "internalType": "uint256", "name": "proposalId", "type": "uint256" },
      { "indexed": false, "internalType": "bool", "name": "approved", "type": "bool" }
    ],
    "name": "Executed",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "proposalCount",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "govToken",
    "outputs": [{ "internalType": "contract GovToken", "name": "", "type": "address" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "string", "name": "_description", "type": "string" },
      { "internalType": "uint256", "name": "_duration", "type": "uint256" },
      { "internalType": "enum DAOGovernance.ProposalType", "name": "_type", "type": "uint8" }
    ],
    "name": "createProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "_proposalId", "type": "uint256" }],
    "name": "vote",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "_proposalId", "type": "uint256" },
      { "internalType": "uint256", "name": "_quorum", "type": "uint256" }
    ],
    "name": "executeProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "_proposalId", "type": "uint256" }],
    "name": "getProposal",
    "outputs": [
      { "internalType": "string", "name": "description", "type": "string" },
      { "internalType": "enum DAOGovernance.ProposalType", "name": "proposalType", "type": "uint8" },
      { "internalType": "uint256", "name": "voteCount", "type": "uint256" },
      { "internalType": "uint256", "name": "deadline", "type": "uint256" },
      { "internalType": "bool", "name": "executed", "type": "bool" },
      { "internalType": "bool", "name": "approved", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "_proposalId", "type": "uint256" },
      { "internalType": "address", "name": "_voter", "type": "address" }
    ],
    "name": "hasVoted",
    "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "_proposalId", "type": "uint256" }],
    "name": "getRemainingTime",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "_proposalId", "type": "uint256" },
      { "internalType": "address", "name": "voter", "type": "address" },
      { "internalType": "uint8", "name": "v", "type": "uint8" },
      { "internalType": "bytes32", "name": "r", "type": "bytes32" },
      { "internalType": "bytes32", "name": "s", "type": "bytes32" }
    ],
    "name": "voteBySig",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
