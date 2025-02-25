## Bridge project

### Token ERC20

- contract src/TG.sol
- calcul
1 once d'or <=> 31 g d'or <=> 31 token Gold

Pay in ETH to receive Gold tokens

Number of Gold tokens = value * 31 / (priceXAU/ETH * 10^18) with value in WEI sent by the caller
XAU/ETH = (XAU/USD)/(ETH/USD)

### Installation

doc : https://github.com/smartcontractkit/chainlink-brownie-contracts

```
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```
Then, update your foundry.toml to include the following in the remappings.

```
remappings = [
  '@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/src/',
]
```



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
