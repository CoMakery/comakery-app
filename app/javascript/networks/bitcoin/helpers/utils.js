const BigNumber = require('bignumber.js')
const axios = require('axios')

function selectTxs(unspentTransactions, amount, fee) {
  unspentTransactions.sort(function(a, b) {return a.satoshis - b.satoshis})

  var value = new BigNumber(amount).plus(fee).times(1e8)
  var find = []
  var findTotal = new BigNumber(0)
  for (var i = 0; i < unspentTransactions.length; i++) {
    var tx = unspentTransactions[i]
    if (tx.confirmations > 0) {
      findTotal = findTotal.plus(tx.satoshis)
      find[find.length] = tx
      if (findTotal.isGreaterThanOrEqualTo(value)) break
    }
  }
  if (value.isGreaterThan(findTotal)) {
    throw new Error('You do not have enough tokens to send')
  }
  return find
}

function getFee() {
  var averageBytes = 255
  return axios.get('https://bitcoinfees.earn.com/api/v1/fees/recommended').then((response) => {
    return (response.data.fastestFee * averageBytes) / 1e8
  }).catch(() => {
    return 0
  });
}

module.exports = { selectTxs, getFee }
