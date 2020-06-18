import axios from 'axios'

export default {
  getInsightBaseUrl(network) {
    let url
    switch (network) {
      case 'testnet':
        url = 'https://test.bitgo.com/api/v1'
        break
      case 'mainnet':
        url = 'https://www.bitgo.com/api/v1'
        break
      default:
    }
    return url
  },

  async getInfo(address, network) {
    const baseApiUrl = this.getInsightBaseUrl(network)
    const rs = (await axios.get(`${baseApiUrl}/address/${address}`)).data
    return {
      address         : rs.address,
      balance         : rs.balance / 1e8,
      balanceSat      : rs.balance,
      confirmedBalance: rs.confirmedBalance
    }
  },

  async getUtxoList(address, network) {
    const baseApiUrl = this.getInsightBaseUrl(network)
    return (await axios.get(`${baseApiUrl}/address/${address}/unspents`)).data.unspents.map(item => {
      return {
        address      : item.address,
        txid         : item.tx_hash,
        confirmations: item.confirmations,
        amount       : item.value / 1e8,
        satoshis     : item.value,
        hash         : item.tx_hash,
        pos          : item.tx_output_n
      }
    })
  }
}
