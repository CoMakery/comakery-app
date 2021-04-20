const chainjs = require("@open-rights-exchange/chainjs")
const BigNumber = require('bignumber.js')
const HotWallet = require("../HotWallet").HotWallet

class EthereumBlockchain {
  constructor(envs) {
    this.envs = envs
    this.blockchainNetwork = envs.blockchainNetwork
    const endpoints = this.endpointsByNetwork(this.blockchainNetwork)
    const chainOptions = this.chainOptions(this.blockchainNetwork)
    this.chain = new chainjs.ChainFactory().create(chainjs.ChainType.EthereumV1, endpoints, chainOptions)
    // It is necessary to cache values gotten from blockchain
    this.ethBalances = {}
    this.tokenBalances = {}
  }

  ropstenEndpoints() {
    return [
      {
        url: `https://ropsten.infura.io/v3/${this.envs.infuraProjectId}`
      }
    ]
  }

  mainnetEndpoints() {
    return [
      {
        url: `https://mainnet.infura.io/v3/${this.envs.infuraProjectId}`
      }
    ]
  }

  endpointsByNetwork(network) {
    switch (network) {
      case 'ethereum_ropsten':
        return this.ropstenEndpoints()
      case 'ethereum':
        return this.mainnetEndpoints()
      default:
        console.error("Unknown or unsupported network")
    }
  }

  ropstenChainOptions() {
    return {
      chainForkType: {
        chainName: 'ropsten',
        hardFork: 'istanbul',
      },
      defaultTransactionSettings: {
        maxFeeIncreasePercentage: 20,
        executionPriority: chainjs.Models.TxExecutionPriority.Fast,
      },
    }
  }

  mainnetChainOptions() {
    return {
      chainForkType: {
        chainName: 'mainnet',
        hardFork: 'istanbul',
      },
      defaultTransactionSettings: {
        maxFeeIncreasePercentage: 20,
        executionPriority: chainjs.Models.TxExecutionPriority.Fast,
      },
    }
  }

  chainOptions(network) {
    switch (network) {
      case 'ethereum_ropsten':
        return this.ropstenChainOptions()
      case 'ethereum':
        return this.mainnetChainOptions()
      default:
        console.error("Unknown or unsupported network")
    }
  }

  createAccountOptions() {
    return {
      newKeysOptions: {
        password: 'hot_wallet_ethereum_pwd',
        salt: 'hot_wallet_ethereum_salt'
      }
    }
  }

  async connect() {
    if (!this.chain.isConnected) {
      await this.chain.connect()
    }
  }

  async generateNewWallet() {
    await this.connect()

    const createAccount = this.chain.new.CreateAccount(this.createAccountOptions())
    await createAccount.generateKeysIfNeeded()

    return new HotWallet(this.blockchainNetwork, createAccount.accountName, createAccount.generatedKeys)
  }

  async getEthBalance(hotWalletAddress) {
    if (hotWalletAddress in this.ethBalances) { return this.ethBalances[hotWalletAddress] }

    await this.connect()
    const blockchainBalance = await this.chain.fetchBalance(hotWalletAddress, chainjs.HelpersEthereum.toEthereumSymbol('eth'))
    this.ethBalances[hotWalletAddress] = new BigNumber(blockchainBalance.balance)

    return this.ethBalances[hotWalletAddress]
  }

  async enoughCoinBalanceToSendTransaction(hotWalletAddress) {
    const balance = await this.getEthBalance(hotWalletAddress)
    return balance.isGreaterThan(new BigNumber(0.001))
  }

  // TODO: fix getting token balance. For now it always returns 0
  async getTokenBalance(hotWalletAddress) {
    if (hotWalletAddress in this.tokenBalances) { return this.tokenBalances[hotWalletAddress] }

    await this.connect()
    const tokenBalance = await this.chain.fetchBalance(hotWalletAddress, chainjs.HelpersEthereum.toEthereumSymbol(this.envs.ethereumTokenSymbol), this.envs.ethereumContractAddress)

    if (tokenBalance.balance) {
      const balance = new BigNumber(tokenBalance.balance)
      this.tokenBalances[hotWalletAddress] = balance
      return balance
    } else {
      return new BigNumber(0)
    }
  }

  async positiveTokenBalance(hotWalletAddress) {
    const tokenBalance = await this.getTokenBalance(hotWalletAddress)
    return tokenBalance.isPositive()
  }

  async isTransactionValid(transaction, hotWalletAddress) {
    if (typeof transaction !== 'string') { return { valid: false } }

    // TODO: Implement me
    return { valid: true }
  }

  async signAndSendTransaction(transaction, hotWallet) {
    await this.connect()

    const chainTransaction = await this.chain.new.Transaction()
    const txn = JSON.parse(transaction.txRaw || "{}")
    console.log(txn);
    // For now hardcoded to ERC20Transfer
    const txToSend = {}
    txToSend.contractAddress = txn.to
    txToSend.from = txn.from
    txToSend.precision = 0
    txToSend.to = txn.to
    txToSend.value = txn.value

    // const action = await this.chain.composeAction(chainjs.ModelsEthereum.EthereumChainActionType.ERC20Transfer, txToSend)

    chainTransaction.actions = [txn]
    await chainTransaction.prepareToBeSigned()
    await chainTransaction.validate()
    await chainTransaction.sign([chainjs.HelpersEthereum.toEthereumPrivateKey(hotWallet.privateKey)])

    try {
      const tx_result = await chainTransaction.send()
      console.log(`Transaction has successfully signed and sent by ${addr} to blockchain tx hash: ${tx_result.transactionId}`)
      return tx_result
    } catch (err) {
      console.error(err)
      return {}
    }
  }
}
exports.EthereumBlockchain = EthereumBlockchain
