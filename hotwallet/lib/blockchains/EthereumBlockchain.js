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

  mainnetEndpoints() {
    return [
      {
        url: `https://mainnet.infura.io/v3/${this.envs.infuraProjectId}`
      }
    ]
  }

  ropstenEndpoints() {
    return [
      {
        url: `https://ropsten.infura.io/v3/${this.envs.infuraProjectId}`
      }
    ]
  }

  rinkebyEndpoints() {
    return [
      {
        url: `https://rinkeby.infura.io/v3/${this.envs.infuraProjectId}`
      }
    ]
  }

  endpointsByNetwork(network) {
    switch (network) {
      case 'ethereum':
        return this.mainnetEndpoints()
      case 'ethereum_ropsten':
        return this.ropstenEndpoints()
      case 'ethereum_rinkeby':
        return this.rinkebyEndpoints()

      default:
        console.error("Unknown or unsupported network")
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

  rinkebyChainOptions() {
    return {
      chainForkType: {
        chainName: 'rinkeby',
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
      case 'ethereum':
        return this.mainnetChainOptions()
      case 'ethereum_ropsten':
        return this.ropstenChainOptions()
      case 'ethereum_rinkeby':
        return this.rinkebyChainOptions()
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

  approveAbi() {
    return [
      {
        constant: false,
        inputs: [
          {
            name: '_spender',
            type: 'address'
          },
          {
            name: '_value',
            type: 'uint256'
          }
        ],
        name: 'approve',
        outputs: [
          {
            name: '',
            type: 'bool'
          }
        ],
        payable: false,
        stateMutability: 'nonpayable',
        type: 'function'
      }
    ]
  }

  maxPossibleAmount() {
    return '115792089237316195423570985008687907853269984665640564039457584007913129639935'
  }

  approveTxObject(hotWalletAddress, contractAddress, approvalContractAddress) {
    return {
      from: hotWalletAddress,
      to: contractAddress,
      contract: {
        abi: this.approveAbi(),
        method: 'approve',
        parameters: [approvalContractAddress, this.maxPossibleAmount()]
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

  async approveContractTransactions(hotWallet, contractAddress, approvalContractAddress) {
    await this.connect()

    const txn = this.approveTxObject(hotWallet.address, contractAddress, approvalContractAddress)
    txn.data = chainjs.HelpersEthereum.generateDataFromContractAction(txn.contract)

    const chainTransaction = await this.chain.new.Transaction()

    try {
      await chainTransaction.setFromRaw(txn)
      await chainTransaction.prepareToBeSigned()
      await chainTransaction.validate()
      await chainTransaction.sign([chainjs.HelpersEthereum.toEthereumPrivateKey(hotWallet.privateKey)])
      const tx_result = await chainTransaction.send(chainjs.Models.ConfirmType.After001)
      console.log(`Approve contract transaction has successfully sent by ${hotWallet.address} to blockchain tx hash: ${tx_result.transactionId}`)
      return tx_result
    } catch (err) {
      console.error(err)
      return { valid: false, error: err.message }
    }
  }

  async getEthBalance(hotWalletAddress) {
    if (hotWalletAddress in this.ethBalances) { return this.ethBalances[hotWalletAddress] }

    await this.connect()
    const blockchainBalance = await this.chain.fetchBalance(hotWalletAddress, chainjs.HelpersEthereum.toEthereumSymbol('eth'))
    this.ethBalances[hotWalletAddress] = new BigNumber(blockchainBalance.balance || 0)

    return this.ethBalances[hotWalletAddress]
  }

  async enoughCoinBalanceToSendTransaction(hotWalletAddress) {
    const balance = await this.getEthBalance(hotWalletAddress)
    return balance.isGreaterThan(new BigNumber(0.001))
  }

  async tokenContract(tokenAddress) {
    await this.connect()

    return new this.chain.web3.eth.Contract(this.balanceAbi(), tokenAddress)
  }

  async getTokenBalance(hotWalletAddress) {
    if (hotWalletAddress in this.tokenBalances) { return this.tokenBalances[hotWalletAddress] }

    await this.connect()
    // Chainjs version does not work for some reason so I implemented custom check using web3
    // const tokenBalance = await this.chain.fetchBalance(hotWalletAddress, chainjs.HelpersEthereum.toEthereumSymbol(this.envs.ethereumTokenSymbol), this.envs.ethereumContractAddress)

    let contractAddress = this.envs.ethereumContractAddress.toString()

    // For Lockup contract we check balance of erc20 contract
    if (this.envs.ethereumTokenType == 'token_release_schedule') {
      contractAddress = this.envs.ethereumApprovalContractAddress.toString()
    }

    const contract = await this.tokenContract(contractAddress)
    const balanceRes = await contract.methods.balanceOf(hotWalletAddress).call()
    const decimals = await contract.methods.decimals().call()

    if (balanceRes && decimals) {
      const divisor = new BigNumber(10).pow(decimals)
      const balance = new BigNumber(balanceRes).div(divisor)

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

  async isTransactionValid(blockchainTransaction, hotWalletAddress) {
    if (typeof blockchainTransaction.txRaw !== 'string') { return { valid: false } }

    try {
      const amount = new BigNumber(blockchainTransaction.amount)

      // validate enough tokens
      if (amount.isGreaterThan(new BigNumber(0))) {
        const tokenBalance = await this.getTokenBalance(hotWalletAddress)

        if (tokenBalance.isLessThan(amount)) {
          const errorMessage = `The Hot Wallet has insufficient tokens. Please top up the ${hotWalletAddress}`
          console.log(errorMessage)
          return { valid: false, markAs: "cancelled", error: errorMessage }
        }
      }

      return { valid: true }
    } catch (err) {
      return { valid: false, markAs: "failed", error: `Unknown error: ${err}` }
    }
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
      const tx_result = await chainTransaction.send(chainjs.Models.ConfirmType.After001)
      console.log(`Transaction has successfully signed and sent by ${hotWallet.address} to blockchain tx hash: ${tx_result.transactionId}`)
      return tx_result
    } catch (err) {
      console.error(err)
      return { valid: false, markAs: "failed", error: err.message }
    }
  }
}
exports.EthereumBlockchain = EthereumBlockchain
