# Carbon-2535 (WIP)
## Simplified, industrial jargon free implementation of EIP2535 (Diamond Standard)

### [Install Foundry](https://getfoundry.sh/)
`curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup`

### Install dependency
`forge install foundry-rs/forge-std --no-commit --no-git`

## Description Report Generated using Sūrya



### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |

### Files Description Table

|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./src/Diamond.sol | 637b2b34f5ff3c4f905e58944b0e1d41c6262505 |
| ./src/contracts/Utils.sol | 6205892d4129d0338fb26c06e30aaa5b667c7f2d |
| ./src/Core.sol | ddd30661d8dbcc5f27f05baa8c6dae92322f3933 |
| ./src/interface/iERC165.sol | 955da4b0a599d4db5c02b1d453c2def2eec25057 |
| ./src/interface/iERC173.sol | b7c300ef630a3ab13f311ce018f6971eca65c069 |
| ./src/contracts/Manager.sol | a930edb9dd00c7162449905c275af839d0035498 |
| ./src/Carbon.sol | 6ab10d0acbfe9f3d7647b01457518220709d8550 |
| ./src/Core.sol | 9633ae97762a1f63b4946e760af622e93ba82fc0 |


 Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **Diamond** | Implementation | iERC165 |||
| └ | supportsInterface | External ❗️ |   |NO❗️ |
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | toggle | External ❗️ | 🛑  |NO❗️ |
| └ | <Fallback> | External ❗️ |  💵 |NO❗️ |
| └ | <Receive Ether> | External ❗️ |  💵 |NO❗️ |
||||||
| **Utils** | Implementation | Core, iERC173 |||
| └ | owner | External ❗️ |   |NO❗️ |
| └ | transferOwnership | External ❗️ | 🛑  |NO❗️ |
| └ | acceptOwnership | External ❗️ | 🛑  |NO❗️ |
||||||
| **Core** | Implementation |  |||
||||||
| **_events** | Implementation |  |||
||||||
| **iERC165** | Interface |  |||
| └ | supportsInterface | External ❗️ |   |NO❗️ |
||||||
| **iERC173** | Interface |  |||
| └ | owner | External ❗️ |   |NO❗️ |
| └ | transferOwnership | External ❗️ | 🛑  |NO❗️ |
| └ | acceptOwnership | External ❗️ | 🛑  |NO❗️ |
||||||
| **Manager** | Implementation | Core, Utils |||
| └ | newContract | External ❗️ | 🛑  |NO❗️ |
| └ | removeContract | External ❗️ | 🛑  |NO❗️ |
| └ | replaceContract | External ❗️ | 🛑  |NO❗️ |
| └ | addFunctions | External ❗️ | 🛑  |NO❗️ |
| └ | removeFunctions | External ❗️ | 🛑  |NO❗️ |
| └ | replaceFunctions | External ❗️ | 🛑  |NO❗️ |
||||||
| **Carbon** | Library |  |||
| └ | newContract | Internal 🔒 | 🛑  | |
| └ | removeContract | Internal 🔒 | 🛑  | |
| └ | replaceContract | Internal 🔒 | 🛑  | |
| └ | addFunctions | Internal 🔒 | 🛑  | |
| └ | removeFunctions | Internal 🔒 | 🛑  | |
| └ | replaceFunctions | Internal 🔒 | 🛑  | |
||||||
| **Core** | Implementation |  |||

