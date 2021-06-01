# Hotwallet

## Deploy to Heroku

### Preparing

You need to prepare `PROJECT_API_KEY` before deploy. It can be generated in the project's settings on Comakery.

### One-click Deploy

Open project's transfers page as an admin. You will see "Deploy a hot wallet" link if it not deployed yet.
In this way it fill all necessary fields except of `PROJECT_API_KEY`, so fill this field manually.

##### Important note:

For projects with attached `LockupToken` contract you also must fill `ETHEREUM_APPROVAL_CONTRACT_ADDRESS` manully.
It should be filled with basic ERC20 contract address which the LockupToken contract operates.

### Manual Deploy

As an alternative you can click the link bellow and fill all ENVs manully but you must know what to do.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet)

### Preparing of the Hot Wallet

After successful deploy you can see the Hot Wallet address on the Project's transfers page.
Now we must configure this wallet to be able to sign and transfer transactions.

#### Top up ETHs

First of all the How Wallet must have enough ETHs to pay a fee for each transaction, so you should top up the Hot Wallet address.

#### Top up tokens

To send tokens the How Wallet must have enough token balance, so top up the Hot Wallet address with tokens.

### Setup development enviroment:
```shell
yarn install
cp .env.example .env
```

Change ENV variables to actual in `.env` file.

### Manage process:
```shell
bin/start   # Start hotwallet
bin/stop    # Stop hotwallet
bin/restart # Restart hotwallet
bin/list    # List processes
bin/logs    # Show logs
```

### Run tests:
```shell
yarn test
```
