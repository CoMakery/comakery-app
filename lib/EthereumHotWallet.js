class EthereumHotWallet {
  constructor(network, address, keys, options = {}) {
    this.network = network
    this.address = address
    this.privateKey = keys.privateKey
    this.publicKey = keys.publicKey
    this.privateKeyEncrypted = keys.privateKeyEncrypted
    this.approvedContract = options.approvedContract || null
  }

  isReadyToSendTx(envs) {
    return this.isApprovedContract(envs.ethereumApprovalContractAddress)
  }

  isApprovedContract(approvalContractAddress) {
    if (!this.approvedContract) { return false }

    return this.approvedContract === approvalContractAddress
  }
}

exports.EthereumHotWallet = EthereumHotWallet
