# LendCredX: Credit-Based Lending Protocol

A decentralized lending protocol on Stacks blockchain that enables credit score based lending in STX tokens.

## Overview

LendCredX allows users to borrow STX tokens based on their assigned credit scores. The protocol features:

- Credit scores range from 100-1000
- Interest rates dynamically adjust based on credit score 
- No collateral required - loans based purely on credit score
- Built-in penalty system for defaults

## Smart Contract Functions

### Core Functions

```clarity
;; Deposit STX into lending pool
(contract-call? .lendcredx deposit-funds amount)

;; Borrow STX (amount limited by credit score)
(contract-call? .lendcredx borrow amount)

;; Repay loan with interest
(contract-call? .lendcredx repay-loan amount)
```

### Admin Functions

```clarity
;; Set user credit score (100-1000)
(contract-call? .lendcredx set-credit user score)

;; Apply penalty for defaults
(contract-call? .lendcredx penalize user amount)
```

### View Functions

```clarity
;; Get user's credit score and loan details
(contract-call? .lendcredx get-user-status user)

;; Get total pool stats
(contract-call? .lendcredx get-pool-stats)

;; Calculate interest rate for credit score
(contract-call? .lendcredx calc-interest score)
```

## How It Works

1. Admin assigns credit scores to users (100-1000)
2. Users can borrow up to: `(credit-score * 10) / 1000` STX
3. Interest rate = 5% - (credit-score / 200)
4. Better credit scores = higher borrowing limits and lower rates

## Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Node.js

### Running Tests
```bash
npm test
```

### Contract Check
```bash
clarinet check
```

## Security Features

- Only admin can set credit scores
- Borrowing limits strictly enforced by credit score
- Built-in penalties for defaults
- Math operations protected against overflow
