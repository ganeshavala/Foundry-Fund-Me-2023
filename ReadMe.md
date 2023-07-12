 `README.md` file for the `FundMe` contract:

```markdown
# FundMe

The `FundMe` contract is written in Solidity and allows users to fund the contract with Ether. The contract keeps track of the amount funded by each user and allows the contract owner to withdraw the funds and reset the funding amounts.

## Features

- Users can fund the contract with Ether
- The contract keeps track of the amount funded by each user
- The contract owner can withdraw the funds and reset the funding amounts
- The contract has a minimum funding amount, which is converted from USD to Ether using a price feed from Chainlink
- The contract has fallback and receive functions that call the `fund` function when Ether is sent to the contract

## Usage

1. Deploy the `FundMe` contract and pass in the address of a Chainlink price feed as an argument to the constructor
2. Users can fund the contract by calling the `fund` function or sending Ether directly to the contract
3. The contract owner can withdraw the funds by calling the `withdraw` function
4. Anyone can view information about funding amounts, funders, and owner by calling the view functions

## Functions

- `fund`: Allows users to send Ether to the contract. Checks if the value sent is greater than or equal to a minimum amount in USD.
- `getVersion`: Returns the version of the price feed.
- `withdraw`: Can only be called by the owner of the contract. Resets all funding amounts and transfers all Ether in the contract to the owner.
- `fallback` and `receive`: Call the `fund` function when Ether is sent to the contract.
- View functions: Allow anyone to get information about funding amounts, funders, and owner.

```
