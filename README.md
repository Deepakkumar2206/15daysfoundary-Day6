# Auction Contract (Foundry)


## This project demonstrates a simple Ethereum auction smart contract where users can place bids, withdraw previous bids, and the owner can end the auction. Events are indexed for easier tracking of bidders and winners.

### Key Concepts

- vm.warp(timestamp) - Moves blockchain time forward to test time-based logic (e.g., ending an auction).
- vm.expectEmit() - Tells Foundry to expect a specific event in the next transaction. Useful to verify HighestBidIncreased or AuctionEnded.
- eventlogs - Captures and inspects emitted events during contract execution.
- Time-based logic - Contracts using block.timestamp (like auction end) require manipulating time in tests to simulate future scenarios.

### Prerequisites

Install Foundry (Forge, Cast, Anvil):

```shell
curl -L https://foundry.paradigm.xyz | bash

foundryup
```

### What is foundry.toml?

Foundry’s config file for Solidity projects. It defines:
- Solidity version
- Optimizer settings
- Output folder and remappings

Example:

```shell
[profile.default]
src = 'src'
out = 'out'
libs = ['lib']
optimizer = true
optimizer_runs = 200
```



### Contracts Explanation

#### Auction.sol

#### Implements a single auction smart contract:
- Users can place bids (bid())
- Previous highest bidder can withdraw funds (withdraw())
- Owner can end the auction and receive the highest bid (endAuction())
- Uses mapping(address => uint256) to track pending returns.
- Events are indexed (HighestBidIncreased and AuctionEnded) for easy filtering.

#### Security measures:
- Only the owner can end the auction (onlyOwner)
- Prevents overwriting bids without refunding previous bidder

#### Test File
- Auction.t.sol (or equivalent)
- Tests bidding: ensures bids update highestBid and highestBidder.
- Tests withdrawals: checks previous bidders can withdraw their funds.
- Tests auction end: verifies only the owner can end the auction and highest bid is transferred.
- Uses Foundry’s forge test framework.
- Shows pass/fail output for all functions.


### Sample Output

- User Alice bids 1 ETH:
```shell
HighestBidIncreased: bidder=Alice, amount=1 ETH
```

- User Bob bids 2 ETH:
```shell
HighestBidIncreased: bidder=Bob, amount=2 ETH
```

- Owner ends the auction:
```shell
AuctionEnded: winner=Bob, amount=2 ETH
```

### Explanation

- Each new bid updates highestBidder and highestBid.
- Previous bidders can withdraw funds using withdraw().
- Owner receives the final highest bid once the auction ends.

### Build & Test Commands

```shell
# Compile contracts
forge build

# Run tests
forge test -vv

# Optional: snapshot for testing state
forge snapshot
```

### End of the Project.



