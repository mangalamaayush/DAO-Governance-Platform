const govTokenAddress = "YOUR_GOVTOKEN_ADDRESS";
const daoAddress = "YOUR_DAOGOVERNANCE_ADDRESS";

// Replace with your ABIs
const govTokenABI = [ /* GovToken ABI here */ ];
const daoABI = [ /* DAO Governance ABI here */ ];

let provider, signer, daoContract, tokenContract, currentAccount;

document.getElementById("connectWallet").onclick = async () => {
  provider = new ethers.providers.Web3Provider(window.ethereum);
  await provider.send("eth_requestAccounts", []);
  signer = provider.getSigner();
  currentAccount = await signer.getAddress();
  document.getElementById("walletInfo").innerText = `Connected: ${currentAccount}`;

  daoContract = new ethers.Contract(daoAddress, daoABI, signer);
  tokenContract = new ethers.Contract(govTokenAddress, govTokenABI, signer);

  loadProposals();
};

async function loadProposals() {
  const list = document.getElementById("proposalsList");
  list.innerHTML = "";
  const count = await daoContract.proposalCount();

  for (let i = 1; i <= count; i++) {
    const proposal = await daoContract.getProposal(i);
    const voted = await daoContract.hasVoted(i, currentAccount);
    const remaining = await daoContract.getRemainingTime(i);

    const div = document.createElement("div");
    div.innerHTML = `
      <p><strong>ID:</strong> ${i}</p>
      <p><strong>Description:</strong> ${proposal[0]}</p>
      <p><strong>Type:</strong> ${["GENERAL", "FUNDING", "TECHNICAL"][proposal[1]]}</p>
      <p><strong>Votes:</strong> ${proposal[2]}</p>
      <p><strong>Ends in:</strong> ${remaining} seconds</p>
      <p><strong>Status:</strong> ${proposal[4] ? "Executed" : "Pending"} | Approved: ${proposal[5]}</p>
      ${!voted && remaining > 0 ? `<button onclick="vote(${i})">Vote</button>` : "<em>Already voted or closed</em>"}
      ${proposal[4] ? "" : `<button onclick="execute(${i})">Execute</button>`}
      <hr/>
    `;
    list.appendChild(div);
  }
}

async function vote(id) {
  const tx = await daoContract.vote(id);
  await tx.wait();
  alert("Voted successfully!");
  loadProposals();
}

async function execute(id) {
  const quorum = prompt("Enter quorum threshold:");
  const tx = await daoContract.executeProposal(id, quorum);
  await tx.wait();
  alert("Executed!");
  loadProposals();
}

document.getElementById("delegateBtn").onclick = async () => {
  const to = document.getElementById("delegateTo").value;
  const tx = await tokenContract.delegate(to);
  await tx.wait();
  alert("Delegated!");
};

document.getElementById("createProposal").onclick = async () => {
  const desc = document.getElementById("description").value;
  const type = document.getElementById("type").value;
  const duration = document.getElementById("duration").value;
  const tx = await daoContract.createProposal(desc, duration, type);
  await tx.wait();
  alert("Proposal created!");
  loadProposals();
};
