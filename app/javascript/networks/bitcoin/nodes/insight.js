import axios from 'axios'

export default {
  getInsightBaseUrl(network) {
    let url
    switch (network) {
      case 'testnet':
        url = 'https://test-insight.bitpay.com/api'
        break
      case 'mainnet':
        url = 'https://insight.bitpay.com/api'
        break
      default:
    }
    return url
  },

  async getInfo(address, network) {
    const baseApiUrl = this.getInsightBaseUrl(network)
    return (await axios.get(`${baseApiUrl}/addr/${address}`)).data
  },

  async getUtxoList(address, network) {
    const baseApiUrl = this.getInsightBaseUrl(network)
    return (await axios.get(`${baseApiUrl}/addr/${address}/utxo`)).data.map(item => {
      return {
        address      : item.address,
        txid         : item.txid,
        confirmations: item.confirmations,
        amount       : item.amount,
        satoshis     : item.satoshis,
        hash         : item.txid,
        pos          : item.vout
      }
    })
  },
}
