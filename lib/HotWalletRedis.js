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
    const keys = []
    let key = null
    let values = null

    if (tx.blockchainTransactableType && tx.blockchainTransactableId) {
      this.transactableKeyName(tx.blockchainTransactableType, tx.blockchainTransactableId)
      keys.push(this.transactableKeyName(tx.blockchainTransactableType, tx.blockchainTransactableId))
    } else if (Array.isArray(tx.blockchainTransactables) && tx.blockchainTransactables.length > 0) {
      tx.blockchainTransactables.forEach((bt) => {
        keys.push(this.transactableKeyName(bt.blockchainTransactableType, bt.blockchainTransactableId))
      })
    }

    for (var i = 0; i < keys.length; i++) {
      values = await this.hgetall(keys[i])
      if (values) {
        key = keys[i]
        break
      }
    }

    if (values && key) {
      return { key: key, values: values }
    } else {
      return null
    }
  }

  async saveDavaForTransaction(status, type, id, txHash) {
    const key = this.transactableKeyName(type, id)
    const monthInSeconds = 60*60*24*30

    await this.hset(key,
      "status", status,
      "txHash", txHash,
      "createdAt", Date.now(),
    )
    await this.expire(key, monthInSeconds)
    return true
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
