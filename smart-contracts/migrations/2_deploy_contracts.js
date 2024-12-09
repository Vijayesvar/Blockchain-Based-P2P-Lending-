const SafeMath = artifacts.require("../contracts/common/SafeMath.sol");
const Destructible = artifacts.require("../contracts/common/Destructible.sol");
const Ownable = artifacts.require("../contracts/common/Ownable.sol");
const Credit = artifacts.require("../contracts/Credit.sol");
const PeerToPeerLending = artifacts.require("../contracts/PeerToPeerLending.sol");

module.exports = async function (deployer, network, accounts) {
    // Deploy libraries first
    await deployer.deploy(SafeMath, { from: accounts[0] });
    await deployer.deploy(Destructible, { from: accounts[0] });
    await deployer.deploy(Ownable, { from: accounts[0] });

    // Link libraries to dependent contracts
    await deployer.link(SafeMath, [Credit, PeerToPeerLending]);
    await deployer.link(Destructible, [Credit, PeerToPeerLending]);

    // Define the constructor arguments for the Credit contract
    const requestedAmount = web3.utils.toWei('10', 'ether');  // Example: 10 ETH
    const requestedRepayments = 10;  // Example: 10 repayments
    const interest = web3.utils.toWei('1', 'ether');  // Example: 1 ETH as interest
    const description = web3.utils.fromAscii('Loan for car purchase');

    // Deploy the Credit contract with constructor arguments
    await deployer.deploy(Credit, requestedAmount, requestedRepayments, interest, description, { from: accounts[0] });

    // Deploy the PeerToPeerLending contract
    await deployer.deploy(PeerToPeerLending, { from: accounts[0] });
};

