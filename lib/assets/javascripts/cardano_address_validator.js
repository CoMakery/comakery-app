module.exports = {
  checkValidAddress: function(address) {
    const {isValidAddress} = require('cardano-crypto.js')

    if (isValidAddress(address)) {
      return true
    } else {
      return false
    }
  }
};
