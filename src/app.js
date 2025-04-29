import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import "./style.css";

// Smart Contract Details
const CONTRACT_ADDRESS = "0x3Cb156Dd68f87c8DA2c016A10feC397FfF6ff3c5";
const CONTRACT_ABI = [
  {
    "inputs": [
      { "internalType": "string", "name": "_description", "type": "string" }
    ],
    "name": "createProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getAllProposals",
    "outputs": [
      { "internalType": "uint256[]", "name": "", "type": "uint256[]" },
      { "internalType": "string[]", "name": "", "type": "string[]" },
      { "internalType": "uint256[]", "name": "", "type": "uint256[]" },
      { "internalType": "bool[]", "name": "", "type": "bool[]" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getWinningProposal",
    "outputs": [
      { "internalType": "uint256", "name": "winningProposalId", "type": "uint256" },
      { "internalType": "string", "name": "description", "type": "string" },
      { "internalType": "uint256", "name": "highestVoteCount", "type": "uint256" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      { "internalType": "address", "name": "", "type": "address" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "_proposalId", "type": "uint256" }
    ],
    "name": "vote",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "_proposalId", "type": "uint256" }
    ],
    "name": "executeProposal",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

function App() {
  const [account, setAccount] = useState("");
  const [daoContract, setDaoContract] = useState(null);
  const [proposals, setProposals] = useState([]);
  const [newProposal, setNewProposal] = useState("");
  const [owner, setOwner] = useState("");
  const [winningProposal, setWinningProposal] = useState(null);

  // Connect Wallet
  async function connectWallet() {
    if (window.ethereum) {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const accounts = await provider.send("eth_requestAccounts", []);
      setAccount(accounts[0]);

      const signer = await provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
      setDaoContract(contract);

      const ownerAddress = await contract.owner();
      setOwner(ownerAddress);
    } else {
      alert("Install MetaMask first!");
    }
  }

  // Load Proposals
  async function loadProposals() {
    if (daoContract) {
      const [ids, descriptions, voteCounts, executions] = await daoContract.getAllProposals();
      const formatted = ids.map((id, index) => ({
        id: id,
        description: descriptions[index],
        votes: voteCounts[index],
        executed: executions[index]
      }));
      setProposals(formatted);

      const winner = await daoContract.getWinningProposal();
      setWinningProposal(winner);
    }
  }

  // Create Proposal
  async function handleCreateProposal() {
    if (!newProposal) return;
    try {
      const tx = await daoContract.createProposal(newProposal);
      await tx.wait();
      setNewProposal("");
      loadProposals();
    } catch (error) {
      console.error(error);
    }
  }

  // Vote
  async function handleVote(id) {
    try {
      const tx = await daoContract.vote(id);
      await tx.wait();
      loadProposals();
    } catch (error) {
      console.error(error);
    }
  }

  // Execute Proposal
  async function handleExecute(id) {
    try {
      const tx = await daoContract.executeProposal(id);
      await tx.wait();
      loadProposals();
    } catch (error) {
      console.error(error);
    }
  }

  useEffect(() => {
    if (daoContract) {
      loadProposals();
    }
  }, [daoContract]);

  return (
    <div className="container">
      <h1>🗳️ DAO Voting DApp</h1>

      {!account ? (
        <button className="button" onClick={connectWallet}>Connect Wallet</button>
      ) : (
        <div>
          <p>Connected as: {account}</p>
          <p>Owner: {owner}</p>

          {account.toLowerCase() === owner.toLowerCase() && (
            <div className="create-proposal">
              <input
                type="text"
                placeholder="Proposal description"
                value={newProposal}
                onChange={(e) => setNewProposal(e.target.value)}
              />
              <button className="button" onClick={handleCreateProposal}>Create Proposal</button>
            </div>
          )}

          <h2>Proposals</h2>
          {proposals.length === 0 ? (
            <p>No proposals found.</p>
          ) : (
            <div className="proposals">
              {proposals.map((p) => (
                <div key={p.id} className="proposal-card">
                  <h3>Proposal #{p.id.toString()}</h3>
                  <p>{p.description}</p>
                  <p>Votes: {p.votes.toString()}</p>
                  <p>Status: {p.executed ? "✅ Executed" : "🕒 Pending"}</p>

                  {!p.executed && (
                    <div className="buttons">
                      <button className="button" onClick={() => handleVote(p.id)}>Vote</button>
                      {account.toLowerCase() === owner.toLowerCase() && (
                        <button className="button execute" onClick={() => handleExecute(p.id)}>Execute</button>
                      )}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

          {winningProposal && (
            <div className="winner">
              <h2>🏆 Winning Proposal</h2>
              <p>ID: {winningProposal.winningProposalId.toString()}</p>
              <p>Description: {winningProposal.description}</p>
              <p>Votes: {winningProposal.highestVoteCount.toString()}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default App;
