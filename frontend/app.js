import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import './style.css';

const CONTRACT_ADDRESS = "0x3Cb156Dd68f87c8DA2c016A10feC397FfF6ff3c5";

const CONTRACT_ABI = [
  {
    "inputs": [],
    "name": "proposalCount",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "_proposalId", "type": "uint256" }],
    "name": "getProposal",
    "outputs": [
      { "internalType": "uint256", "name": "id", "type": "uint256" },
      { "internalType": "string", "name": "description", "type": "string" },
      { "internalType": "uint256", "name": "voteCount", "type": "uint256" },
      { "internalType": "bool", "name": "executed", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getAllProposals",
    "outputs": [
      { "internalType": "uint256[]", "name": "ids", "type": "uint256[]" },
      { "internalType": "string[]", "name": "descriptions", "type": "string[]" },
      { "internalType": "uint256[]", "name": "voteCounts", "type": "uint256[]" },
      { "internalType": "bool[]", "name": "executions", "type": "bool[]" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "string", "name": "_description", "type": "string" }],
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
    "inputs": [{ "internalType": "uint256", "name": "_proposalId", "type": "uint256" }],
    "name": "executeProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

function App() {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState(null);
  const [proposals, setProposals] = useState([]);
  const [newProposal, setNewProposal] = useState("");

  useEffect(() => {
    const connectWallet = async () => {
      if (window.ethereum) {
        const tempProvider = new ethers.providers.Web3Provider(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        const tempSigner = tempProvider.getSigner();
        const tempContract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, tempSigner);
        const tempAccount = await tempSigner.getAddress();
        
        setProvider(tempProvider);
        setSigner(tempSigner);
        setContract(tempContract);
        setAccount(tempAccount);
      } else {
        alert("Please install MetaMask");
      }
    };

    connectWallet();
  }, []);

  useEffect(() => {
    if (contract) {
      loadProposals();
    }
  }, [contract]);

  const loadProposals = async () => {
    try {
      const [ids, descriptions, voteCounts, executions] = await contract.getAllProposals();
      const tempProposals = ids.map((id, index) => ({
        id: id.toString(),
        description: descriptions[index],
        voteCount: voteCounts[index].toString(),
        executed: executions[index],
      }));
      setProposals(tempProposals);
    } catch (err) {
      console.error("Error loading proposals:", err);
    }
  };

  const handleCreateProposal = async () => {
    if (newProposal.trim() === "") return;
    try {
      const tx = await contract.createProposal(newProposal);
      await tx.wait();
      setNewProposal("");
      loadProposals();
    } catch (err) {
      console.error(err);
    }
  };

  const handleVote = async (id) => {
    try {
      const tx = await contract.vote(id);
      await tx.wait();
      loadProposals();
    } catch (err) {
      console.error(err);
    }
  };

  const handleExecute = async (id) => {
    try {
      const tx = await contract.executeProposal(id);
      await tx.wait();
      loadProposals();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="container">
      <h1>DAO Voting App</h1>
      <p>Connected Account: {account}</p>

      <div className="create-proposal">
        <input
          type="text"
          placeholder="Proposal description"
          value={newProposal}
          onChange={(e) => setNewProposal(e.target.value)}
        />
        <button onClick={handleCreateProposal}>Create Proposal</button>
      </div>

      <h2>All Proposals</h2>
      <div className="proposals-list">
        {proposals.length === 0 && <p>No proposals found.</p>}
        {proposals.map((proposal) => (
          <div key={proposal.id} className="proposal-card">
            <h3>#{proposal.id}: {proposal.description}</h3>
            <p>Votes: {proposal.voteCount}</p>
            <p>Status: {proposal.executed ? "Executed" : "Pending"}</p>
            <button onClick={() => handleVote(proposal.id)}>Vote</button>
            {!proposal.executed && (
              <button onClick={() => handleExecute(proposal.id)}>Execute</button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
