class EthereumHotWallet {
  constructor(network, address, keys, options = {}) {
    this.network = network
    this.address = address
    this.privateKey = keys.privateKey
    this.publicKey = keys.publicKey
    this.privateKeyEncrypted = keys.privateKeyEncrypted
    this.approvedBatchContract = options.approvedBatchContract || null
  }

  isReadyToSendTx(envs) {
    return this.isApprovedBatchContract(envs.ethereumApprovalContractAddress)
  }

  isApprovedBatchContract(batchContractAddress) {
    if (!this.approvedBatchContract) { return false }

    return this.approvedBatchContract === batchContractAddress
  }
}

exports.EthereumHotWallet = EthereumHotWallet
