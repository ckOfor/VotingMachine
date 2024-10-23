# DAO Governance System

## Overview

The DAO Governance System is a decentralized autonomous organization (DAO) platform that enables community governance through smart contracts. Members hold governance tokens to represent their voting power, submit proposals, vote on them, and execute approved proposals automatically. This system ensures transparency, immutability, and incentivizes active participation in governance.

## Contracts

The project consists of several smart contracts:

### Governance Token Contract (`governance-token.clar`)

- **Description**: Handles token issuance, voting, and proposal execution.
- **Functions**:
    - `create-proposal(description: string)`: Creates a new proposal.
    - `vote(proposal-id: uint, support: bool)`: Casts a vote on a proposal.
    - `execute-proposal(proposal-id: uint)`: Executes an approved proposal.
    - `mint(amount: uint, recipient: principal)`: Mints new tokens.
    - `set-contract-owner(new-owner: principal)`: Changes the contract owner.

### Membership Token Contract (`membership-token.clar`)

- **Description**: Manages membership registration and token balances.
- **Functions**:
    - `register-member(recipient: principal)`: Registers a new member and assigns an initial balance.
    - `transfer(amount: uint, recipient: principal)`: Transfers tokens between members.
    - `set-contract-owner(new-owner: principal)`: Changes the contract owner.

### Proposal Voting Contract (`proposal-voting.clar`)

- **Description**: Manages proposals, voting, and proposal execution.
- **Functions**:
    - `create-proposal(description: string)`: Creates a new proposal.
    - `vote(proposal-id: uint, support: bool)`: Votes on a proposal.
    - `execute-proposal(proposal-id: uint)`: Executes an approved proposal.
    - `mint(amount: uint, recipient: principal)`: Mints new tokens.
    - `set-contract-owner(new-owner: principal)`: Changes the contract owner.

### Proposal Execution Contract (`proposal-execution.clar`)

- **Description**: Executes the actions specified in approved proposals.
- **Functions**:
    - `execute-proposal(proposal-id: uint)`: Executes the proposal.
    - `is-proposal-executed(proposal-id: uint)`: Checks if a proposal has been executed.

## Installation

To set up the DAO Governance System, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/dao-governance-system.git

Usage

Deploy and interact with the smart contracts as follows:

	1.	Deploy Contracts:
Use the provided deployment scripts to deploy the contracts to the desired blockchain environment.
2.	Interact with Contracts:
Use a compatible blockchain interface or your own custom scripts to interact with the deployed contracts.

Contributing

Contributions are welcome! Please follow the standard process for submitting pull requests and ensure that all code adheres to the project’s coding standards.

License

This project is licensed under the MIT License. See the LICENSE file for more details.

Contact

For any questions or support, please contact oforchinedukelechi@gmail.com.
