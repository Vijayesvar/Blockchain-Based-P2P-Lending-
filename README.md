# P2P Lending Platform on Custom Blockchain

## Overview
The **P2P Lending Platform** is a decentralized financial application built on a custom blockchain implemented using **Hyperledger Besu** with IBFT 2.0 consensus. This platform enables users to lend and borrow tokens in a peer-to-peer manner, ensuring transparency, trust, and efficiency.

## Features
- **Decentralized Lending and Borrowing**: Users can lend or borrow tokens directly without intermediaries.
- **Dynamic Interest Rates**: Interest rates are calculated using a modular InterestRateModel.
- **Collateral Management**: Borrowers can secure loans with tokenized assets as collateral.
- **Custom Blockchain**: The platform operates on a private blockchain deployed using Hyperledger Besu.
- **Governance Mechanism**: A governance contract ensures protocol upgrades and community-driven decisions.
- **Fee Management**: Transaction fees are dynamically managed and distributed.

## Technology Stack
- **Blockchain**: Hyperledger Besu with IBFT 2.0 consensus
- **Smart Contracts**: Developed using Solidity
- **Backend**: Smart contract logic deployed on a private Hyperledger Besu network


## Deployment

### Prerequisites
1. **Node.js and npm**: Install from [Node.js](https://nodejs.org/).
2. **Truffle Suite**: Install globally using:
   ```bash
   npm install -g truffle
   ```
3. **Hyperledger Besu**: Set up a private blockchain with IBFT 2.0 consensus.

### Deployment

#### Deploy Smart Contracts
- Navigate to the project root:
  ```bash
  cd P2P-Lending-Platform
  ```
- Compile the smart contracts:
  ```bash
  truffle compile
  ```
- Migrate the contracts to your custom blockchain:
  ```bash
  truffle migrate --network besu
  ```

## Configuration

### Hyperledger Besu Network Configuration
Ensure your Besu network is running with the following parameters:
- **Consensus Mechanism**: IBFT 2.0
- **RPC Port**: `8545`
- **Genesis File**: Includes account allocations for initial balances.

### Metamask Configuration
1. Add a new network in Metamask:
   - **Network Name**: Custom Blockchain
   - **RPC URL**: `http://<your-besu-node-ip>:8545`
   - **Chain ID**: Match your Besu network configuration
2. Import the private keys for testing accounts.

## Contracts
- **LendingPlatform.sol**: Core logic for lending and borrowing.
- **Loan.sol**: Manages individual loans.
- **Token.sol**: ERC20 token used for transactions.
- **CollateralManager.sol**: Ensures collateral-backed borrowing.
- **InterestRateModel.sol**: Adjusts interest rates dynamically.
- **Governance.sol**: Enables community-driven changes.
- **UserRegistry.sol**: Handles user registration and verification.
- **FeeManager.sol**: Manages platform fees.


