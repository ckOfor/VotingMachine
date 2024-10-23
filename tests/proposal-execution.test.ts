import { describe, it, expect, beforeEach } from 'vitest';

// Mock Clarity functions and types
const mockClarityValue = (type, value) => ({ type, value });

const uint = (value) => mockClarityValue('uint', value);
const principal = (value) => mockClarityValue('principal', value);

// Mock contract state
let ownerAddress = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
let proposals = {};
let proposalCount = 0;

// Mock contract functions
const createProposal = (description, proposer) => {
  const newProposalId = ++proposalCount;
  proposals[newProposalId] = {
    proposer,
    description,
    forVotes: 0,
    againstVotes: 0,
    startBlock: 1,
    endBlock: 10, // Simulate end after some blocks
    executed: false,
  };
  return { ok: uint(newProposalId) };
};

const voteProposal = (proposalId, support, voterBalance) => {
  if (!proposals[proposalId]) {
    throw new Error('ERR_PROPOSAL_NOT_EXIST');
  }
  
  const proposal = proposals[proposalId];
  
  if (support) {
    proposal.forVotes += voterBalance;
  } else {
    proposal.againstVotes += voterBalance;
  }
  
  proposals[proposalId] = proposal;
  return { ok: true };
};

const executeProposal = (proposalId) => {
  const proposal = proposals[proposalId];
  if (!proposal) {
    throw new Error('ERR_PROPOSAL_NOT_EXIST');
  }
  if (proposal.executed) {
    throw new Error('ERR_PROPOSAL_NOT_ACTIVE');
  }
  if (proposal.forVotes <= proposal.againstVotes) {
    throw new Error('ERR_UNAUTHORIZED');
  }
  proposal.executed = true;
  return { ok: true };
};

const isProposalExecuted = (proposalId) => {
  const proposal = proposals[proposalId];
  return { ok: !!proposal.executed };
};

describe('Proposal Execution Contract Tests', () => {
  beforeEach(() => {
    // Reset state before each test
    proposals = {};
    proposalCount = 0;
  });
  
  it('should create a proposal successfully', () => {
    const result = createProposal('Test Proposal', ownerAddress);
    expect(result).toEqual({ ok: uint(1) });
  });
  
  it('should execute a proposal successfully', () => {
    createProposal('Test Proposal', ownerAddress);
    voteProposal(1, true, 100); // Voting in favor
    const result = executeProposal(1);
    expect(result).toEqual({ ok: true });
    expect(isProposalExecuted(1)).toEqual({ ok: true });
  });
  
  it('should not execute a proposal with more against votes', () => {
    createProposal('Test Proposal', ownerAddress);
    voteProposal(1, false, 100); // Voting against
    expect(() => executeProposal(1)).toThrow('ERR_UNAUTHORIZED');
  });
  
  it('should not allow executing an already executed proposal', () => {
    createProposal('Test Proposal', ownerAddress);
    voteProposal(1, true, 100); // Voting in favor
    executeProposal(1);
    expect(() => executeProposal(1)).toThrow('ERR_PROPOSAL_NOT_ACTIVE');
  });
  
  it('should return false for an unexecuted proposal', () => {
    createProposal('Test Proposal', ownerAddress);
    const result = isProposalExecuted(1);
    expect(result).toEqual({ ok: false });
  });
});
