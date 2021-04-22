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

  balanceAbi() {
    return [{
      inputs: [
        {
          internalType: 'address',
          name: 'account',
          type: 'address',
        },
      ],
      name: 'balanceOf',
      outputs: [
        {
          internalType: 'uint256',
          name: '',
          type: 'uint256',
        },
      ],
      stateMutability: 'view',
      type: 'function',
    }, {
      constant: true,
      inputs: [],
      name: 'decimals',
      outputs: [
        {
          name: 'decimals',
          type: 'uint8',
        },
      ],
      payable: false,
      type: 'function',
    }]
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

  async getTokenBalance(hotWalletAddress) {
    if (hotWalletAddress in this.tokenBalances) { return this.tokenBalances[hotWalletAddress] }

    await this.connect()
    // Chainjs version does not work for some reason so I implemented custom check using web3
    // const tokenBalance = await this.chain.fetchBalance(hotWalletAddress, chainjs.HelpersEthereum.toEthereumSymbol(this.envs.ethereumTokenSymbol), this.envs.ethereumContractAddress)

    const contract = new this.chain._chainState._web3.eth.Contract(this.balanceAbi(), this.envs.ethereumContractAddress.toString())
    const balanceRes = await contract.methods.balanceOf(hotWalletAddress).call()
    const decimals = await contract.methods.decimals().call()
    const divisor = new BigNumber(10).pow(decimals)
    const balance = new BigNumber(balanceRes).div(divisor)

    if (balance) {
      this.tokenBalances[hotWalletAddress] = balance
      return balance
    } else {
      return new BigNumber(0)
    }
  }

  async positiveTokenBalance(hotWalletAddress) {
    const tokenBalance = await this.getTokenBalance(hotWalletAddress)
    return tokenBalance.isGreaterThan(new BigNumber(0))
  }

  async isTransactionValid(transaction, hotWalletAddress) {
    if (typeof transaction !== 'string') { return { valid: false } }

    // TODO: Implement me
    return { valid: true }
  }

  async sendTransaction(transaction, hotWallet) {
    await this.connect()

    const txn = JSON.parse(transaction.txRaw || "{}")
    txn.data = chainjs.HelpersEthereum.generateDataFromContractAction(txn.contract)

    const chainTransaction = await this.chain.new.Transaction()

    try {
      await chainTransaction.setFromRaw(txn)
      await chainTransaction.prepareToBeSigned()
      await chainTransaction.validate()
      await chainTransaction.sign([chainjs.HelpersEthereum.toEthereumPrivateKey(hotWallet.privateKey)])
      const tx_result = await chainTransaction.send()
      console.log(`Transaction has successfully signed and sent by ${hotWallet.address} to blockchain tx hash: ${tx_result.transactionId}`)
      return tx_result
    } catch (err) {
      console.error(err)
      return { valid: false, markAs: "failed", error: err.message }
    }
  }
}
exports.EthereumBlockchain = EthereumBlockchain
