# SHIELDCOIN token contract

The site renders the contents of [`contracts/Shieldcoin.sol`](contracts/Shieldcoin.sol).
Pause controls are defined locally in
[`contracts/PausableWithReason.sol`](contracts/PausableWithReason.sol).

## Run locally

```bash
python3 -m http.server 8000
```

## Compile and test

```bash
npm ci --ignore-scripts
npm run build
SEPOLIA_RPC_URL="https://..." npm test
```

The Hardhat test suite forks Sepolia and checks the deployed contract at
`0x530aFbE13370f66921A5ECcAE9D832Dd55eb823C`.
