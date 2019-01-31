import BigNumber from 'bignumber.js'
import axios from 'axios'

export default {
  selectTxs(unspentTransactions, amount, fee) {
    unspentTransactions.sort((a, b) => { return a.satoshis - b.satoshis })

    let value = new BigNumber(amount).plus(fee).times(1e8)
    let find = []
    let findTotal = new BigNumber(0)
    for (let i = 0; i < unspentTransactions.length; i++) {
      let tx = unspentTransactions[i]
      findTotal = findTotal.plus(tx.satoshis)
      find[find.length] = tx
      if (findTotal.isGreaterThanOrEqualTo(value)) break
    }
    if (value.isGreaterThan(findTotal)) {
      throw new Error('You do not have enough tokens to send')
    }
    return find
  },

  getFee() {
    let averageBytes = 255
    return axios.get('https://bitcoinfees.earn.com/api/v1/fees/recommended').then((response) => {
      return (response.data.fastestFee * averageBytes) / 1e8
    }).catch(() => {
      return 0.0001
    })
  }
}
