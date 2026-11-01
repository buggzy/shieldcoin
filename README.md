# SHIELDCOIN token contract

The canonical token source is
[`contracts/Shieldcoin.solx`](contracts/Shieldcoin.solx), which is rendered by
the site. Pause controls are defined locally in
[`contracts/PausableWithReason.sol`](contracts/PausableWithReason.sol).

## Translate Solx

Install dependencies, then regenerate the Solidity source with:

```bash
npm install
npm run solx:translate
```

`npm run build` always performs this translation before invoking Hardhat.


## Run locally

```bash
python3 -m http.server 8000
```

## Compile and test

```bash
npm install
npm run build
SEPOLIA_RPC_URL="https://..." npm test
```

The Hardhat test suite forks Sepolia and checks the deployed contract at
`0x530aFbE13370f66921A5ECcAE9D832Dd55eb823C`.
