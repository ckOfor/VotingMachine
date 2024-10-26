import { describe, it, expect, beforeEach } from 'vitest';

// Mock Clarity functions and types
const mockClarityValue = (type, value) => ({ type, value });

const uint = (value) => mockClarityValue('uint', value);
const principal = (value) => mockClarityValue('principal', value);

// Mock contract state
let ownerAddress = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
let treasuryBalances = {};
let spendingLimit = 1000000;
let transactionHistory = {};
let transactionCount = 0;
let spendingProposals = {};

// Mock contract functions
const deposit = (token, amount, caller) => {
  if (!treasuryBalances[token]) {
    treasuryBalances[token] = 0;
  }
  treasuryBalances[token] += amount;
  return { ok: true };
};

const executeSpending = (proposalId, caller) => {
  const proposal = spendingProposals[proposalId];
  if (!proposal || !proposal.executed) throw new Error('ERR_UNAUTHORIZED');
  if (treasuryBalances[proposal.token] < proposal.amount) throw new Error('ERR_INSUFFICIENT_FUNDS');
  if (proposal.amount > spendingLimit) throw new Error('ERR_SPENDING_LIMIT_EXCEEDED');
  
  treasuryBalances[proposal.token] -= proposal.amount;
  proposal.executed = true;
  transactionHistory[transactionCount++] = {
    proposalId,
    amount: proposal.amount,
    recipient: proposal.recipient,
    token: proposal.token,
    block: proposal.executionBlock
  };
  return { ok: true };
};

const setSpendingLimit = (newLimit, caller) => {
  if (caller !== ownerAddress) throw new Error('ERR_UNAUTHORIZED');
  spendingLimit = newLimit;
  return { ok: true };
};

const getTreasuryBalance = (token) => {
  return { ok: uint(treasuryBalances[token] || 0) };
};

describe('Treasury Contract Tests', () => {
  beforeEach(() => {
    // Reset state before each test
    treasuryBalances = {};
    spendingLimit = 1000000;
    transactionHistory = {};
    transactionCount = 0;
    spendingProposals = {};
  });
  
  it('should allow deposit of funds into the treasury', () => {
    const token = 'TOKEN1';
    const result = deposit(token, 500, ownerAddress);
    expect(result).toEqual({ ok: true });
    expect(getTreasuryBalance(token)).toEqual({ ok: uint(500) });
  });
  
  it('should execute a spending proposal if conditions are met', () => {
    const token = 'TOKEN1';
    const proposalId = 1;
    deposit(token, 1000, ownerAddress);
    spendingProposals[proposalId] = { amount: 500, recipient: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG', token, executed: false, executionBlock: 123 };
    
    const result = executeSpending(proposalId, ownerAddress);
    expect(result).toEqual({ ok: true });
    expect(getTreasuryBalance(token)).toEqual({ ok: uint(500) });
  });
  
  it('should throw an error if executing spending proposal exceeds limit', () => {
    const token = 'TOKEN1';
    const proposalId = 1;
    deposit(token, 1000, ownerAddress);
    spendingProposals[proposalId] = { amount: 2000000, recipient: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG', token, executed: false, executionBlock: 123 };
    
    expect(() => executeSpending(proposalId, ownerAddress)).toThrow('ERR_SPENDING_LIMIT_EXCEEDED');
  });
  
  it('should update the spending limit if called by contract owner', () => {
    const newLimit = 500000;
    const result = setSpendingLimit(newLimit, ownerAddress);
    expect(result).toEqual({ ok: true });
    expect(spendingLimit).toBe(newLimit);
  });
  
  it('should throw an error if non-owner tries to update the spending limit', () => {
    const newLimit = 500000;
    const nonOwnerAddress = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    expect(() => setSpendingLimit(newLimit, nonOwnerAddress)).toThrow('ERR_UNAUTHORIZED');
  });
});
