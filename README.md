# Market Maker — Experimental Bonding Curve Token

This project implements a simple **on-chain market maker** using a quadratic bonding curve.  
The contract mints tokens on buys, burns tokens on sells, and adjusts price based on total supply.

> **Note:** This is an experimental model intended for learning.  
> It is *not* a production-ready AMM.

---

## How It Works

### **Buy**

- User sends ETH → contract mints tokens.
- Token price follows a quadratic curve:
  \[
  P(x) = m \cdot x^2
  \]
- Minted tokens use 18-decimal fixed-point math.

### **Sell**

- User burns tokens → contract returns ETH.
- Sell pricing uses a discounted slope (0.3) to discourage early pump-and-dump.
- Refund is based on the **post-burn** supply.

---

## Contract Features

- ERC-20 token (`POOL`)
- Quadratic price function for buys
- Discounted price function for sells
- ETH-backed reserve (contract balance)
- Fully on-chain mint/burn mechanics

---

## Running the Project

Install dependencies:

```bash
npm install
```

## Compile

```bash
npx hardhat compile
```

Run tests:

```bash
npx hardhat test
```
