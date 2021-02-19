# Hotwallet

## Deploy to Heroku

### Prepairing

You need prepare some things before deploy:
1. Comakery's Project id with configured Algorand Security Token as a Project's token.
2. URL of you Comakery's Whitelable
3. PROJECT_API_KEY, can be generated in the project's settings on Comakery
4. PURESTAKE_API, get it from https://developer.purestake.io/home
5. To setup and grand roles to the hot wallet you should have access to wallet with Contract admin role

### Deploy

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet)

On the opened page you have to fill ENV's prepared in previous step and click deploy.

### Preparing for the Hot Wallet

After successful deploy you can see the Hot Wallet address on the Project's transfers page. Now we must configure this wallet to be able to sign and transfer transactions.
#### Add ALGOs

First of all the how wallet must have enough ALGOs to pay a fee for each transaction. For testnet you can add ALGOs using [Algorand dispenser](https://bank.testnet.algorand.network/).
#### Opt-in to the algorand security token

To opt in you should go to Heroku, run Heroku console with this command:
```
node optIn.js blockchain_network appIndex
```
Replace `blockchain_network` with `algorand_test` or `algorand`
Replace appIndex with actual Algorand Security Token application index

For example this command will opt in to 13997710 Application on Algorand Testnet blockchain:
```
node optIn.js algorand_test 13997710
```

#### Send special transactions to configure the Hot Wallet on the App

To send below transactions you must have wallet with Contract admin roles. We recommend to add this wallet to [Algosigner](https://chrome.google.com/webstore/detail/algosigner/kmmolakhbgdlpkjkcjkebenjheonagdm) chrome extension and send transactions using [this page](https://purestake.github.io/algosigner-dapp-example/tx-test/signTesting.html)

Before send transactions you should copy `firstRound` and `lastRound` from default transaction and replace it in every transaction.
At the moment it is: `"firstRound":12442137,"lastRound":12443137`
Also change all `CONTRACT_ADMIN_WALLET_ADDRESS` and `HOT_WALLET_ADDRESS` to actual addresses

#### Send transfer restriction transaction:
Args:
  1. freeze: 0 or 1
  2. maxBalance in the smallest token unit
  3. lockUntil a UNIX timestamp. 1 is unlocked
  4. transfer group. 1 is default

```
{"type":"appl","from":"CONTRACT_ADMIN_WALLET_ADDRESS","fee":1000,"firstRound":12423846,"lastRound":12424846,"genesisID":"testnet-v1.0","genesisHash":"SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=","appIndex":13997710, "appOnComplete":0, "appArgs": ["c2V0QWRkcmVzc1Blcm1pc3Npb25z", [0], [150], [1], [1]],"appAccounts": ["HOT_WALLET_ADDRESS"]}
```

#### Send grand role transaction:
Args:
  1. Role. 1 is for Wallet

```
{"type":"appl","from":"CONTRACT_ADMIN_WALLET_ADDRESS","fee":1000,"firstRound":12423846,"lastRound":12424846,"genesisID":"testnet-v1.0","genesisHash":"SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=","appIndex":13997710,"appAccounts":["HOT_WALLET_ADDRESS"],"appArgs":["Z3JhbnRSb2xlcw==", [1]],"appOnComplete":0}
```

#### [Optional] Mint tokens

You can add tokens to the Hot Wallet 2 ways:
1. Just send from another wallet
2. To mint tokens using the transaction below

Args:
  1. Amount of tokens to mint

```
{"type":"appl","from":"CONTRACT_ADMIN_WALLET_ADDRESS","fee":1000,"firstRound":12423846,"lastRound":12424846,"genesisID":"testnet-v1.0","genesisHash":"SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=","appIndex":13997710, "appOnComplete":0, "appArgs": ["bWludA==", [100]],"appAccounts": ["HOT_WALLET_ADDRESS"]}
```

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
