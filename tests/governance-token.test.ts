import { describe, it, expect, beforeEach } from 'vitest';

// Mock Clarity functions and types
const mockClarityValue = (type: string, value: any) => ({ type, value });

const uint = (value: number) => mockClarityValue('uint', value);
const bool = (value: boolean) => mockClarityValue('bool', value);
const principal = (value: string) => mockClarityValue('principal', value);

// Mock contract state
let ownerAddress = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
let balances: { [key: string]: number } = {};

// Mock contract functions
const mint = (amount: number, recipient: string, caller: string) => {
  if (caller !== ownerAddress) {
    throw new Error('ERR_NOT_AUTHORIZED');
  }
  balances[recipient] = (balances[recipient] || 0) + amount;
  return { ok: true };
};

const transfer = (amount: number, sender: string, recipient: string) => {
  if (!balances[sender] || balances[sender] < amount) {
    throw new Error('ERR_INSUFFICIENT_BALANCE');
  }
  balances[sender] -= amount;
  balances[recipient] = (balances[recipient] || 0) + amount;
  return { ok: true };
};

const getBalance = (address: string) => {
  return { ok: uint(balances[address] || 0) };
};

describe('Governance Token Contract Tests', () => {
  beforeEach(() => {
    // Reset balances before each test
    balances = {};
  });
  
  it('should mint tokens successfully', () => {
    const result = mint(100, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', ownerAddress);
    expect(result).toEqual({ ok: true });
    expect(getBalance('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')).toEqual({ ok: uint(100) });
  });
  
  it('should transfer tokens between accounts', () => {
    mint(100, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', ownerAddress);
    const result = transfer(50, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
    expect(result).toEqual({ ok: true });
    expect(getBalance('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')).toEqual({ ok: uint(50) });
    expect(getBalance('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG')).toEqual({ ok: uint(50) });
  });
  
  it('should return correct balance for an account', () => {
    mint(100, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', ownerAddress);
    const result = getBalance('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM');
    expect(result).toEqual({ ok: uint(100) });
  });
  
  it('should not allow minting by non-owner', () => {
    const nonOwnerAddress = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    expect(() => mint(100, nonOwnerAddress, nonOwnerAddress)).toThrow('ERR_NOT_AUTHORIZED');
  });
  
  it('should not allow transfer of more tokens than balance', () => {
    mint(50, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', ownerAddress);
    const sender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    const recipient = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    expect(() => transfer(100, sender, recipient)).toThrow('ERR_INSUFFICIENT_BALANCE');
  });
});
