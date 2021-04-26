const { promisify } = require("util")
const HotWallet = require("./HotWallet").HotWallet

class HotWalletRedis {
  constructor(envs, redisClient) {
    this.envs = envs
    this.client = redisClient

    // Set error handler
    this.client.on("error", function (err) {
      console.error(`Redis client error: ${err}`);
    })
  }

  walletKeyName() {
    return `wallet_for_project_${this.envs.projectId}`
  }

  transactableKeyName(type, id) {
    return `bt_${type}#${id}` // for example bt-Award#24
  }

  async hotWallet() {
    const savedHW = await this.hgetall(this.walletKeyName())

    if (savedHW) {
      const network = savedHW.network || this.envs.blockchainNetwork
      const optedInApps = JSON.parse(savedHW.optedInApps || "[]")
      const keys = {
        publicKey: savedHW.publicKey,
        privateKey: savedHW.privateKey,
        privateKeyEncrypted: savedHW.privateKeyEncrypted
      }

      return new HotWallet(network, savedHW.address, keys, optedInApps)
    } else {
      return undefined
    }
  }

  async hotWalletAddress() {
    return await this.hget(this.walletKeyName(), "address")
  }

  async hotWalletMnenonic() {
    return await this.hget(this.walletKeyName(), "mnemonic")
  }

  async isHotWalletCreated() {
    return (await this.hotWallet()) !== undefined
  }

  async saveNewHotWallet(wallet) {
    await this.hset(
      this.walletKeyName(),
      "address", wallet.address,
      "privateKey", wallet.privateKey,
      "publicKey", wallet.publicKey,
      "privateKeyEncrypted", wallet.privateKeyEncrypted
      )
    console.log(`Keys for a new hot wallet has been saved into ${this.walletKeyName()}`)
    return true
  }

  async saveOptedInApps(optedInApps) {
    optedInApps = JSON.stringify(optedInApps)
    await this.hset(this.walletKeyName(), "optedInApps", optedInApps)
    console.log(`Opted-in apps (${optedInApps}) has been saved into ${this.walletKeyName()}`)
    return true
  }

  async deleteCurrentKey() {
    await this.del(this.walletKeyName())
    console.log(`Wallet keys has been deleted: ${this.walletKeyName()}`)
    return true
  }

  async getSavedDataForTransaction(tx) {
    const key = this.transactableKeyName(tx.blockchainTransactableType, tx.blockchainTransactableId)
    const values = await this.hgetall(key)

    if (values) {
      return { key: key, values: values }
    } else {
      return null
    }
  }

  async saveDavaForTransaction(txResult) {
    const bt = txResult.blockchainTransaction
    const tx = txResult.transaction
    const key = this.transactableKeyName(bt.blockchainTransactableType, bt.blockchainTransactableId)
    const monthInSeconds = 60*60*24*30

    await this.hset(key,
      "status", txResult.status,
      "txHash", tx.transactionId,
      "createdAt", Date.now(),
    )
    await this.expire(key, monthInSeconds)
    console.log(`saved to ${key}`);
  }

  async hset(...args) {
    return await (promisify(this.client.hset).bind(this.client))(...args)
  }

  async hget(...args) {
    return await (promisify(this.client.hget).bind(this.client))(...args)
  }

  async hgetall(...args) {
    return await (promisify(this.client.hgetall).bind(this.client))(...args)
  }

  async del(...args) {
    return await (promisify(this.client.del).bind(this.client))(...args)
  }

  async expire(...args) {
    return await (promisify(this.client.expire).bind(this.client))(...args)
  }
}
exports.HotWalletRedis = HotWalletRedis
