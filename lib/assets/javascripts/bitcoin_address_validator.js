module.exports = {
  checkValidBitcoinAddress: function(address) {
    const caValidator = require('crypto-address-validator')

    if (caValidator.validate(address, 'BTC', 'both')) {
      return true
    } else {
      return false
    }
  }
};
