const {isValidAddress} = require('cardano-crypto.js')

const {validateMnemonic, validatePaperWalletMnemonic} = require('../wallet/mnemonic')

const parseCoins = (str) => Math.trunc(parseFloat(str) * 1000000)

export const sendAddressValidator = (fieldValue) => {
  return {
    fieldValue,
    validationError: !isValidAddress(fieldValue) ? {code: 'SendAddressInvalidAddress'} : null,
  }
}

export const sendAmountValidator = (fieldValue) => {
  let validationError = null
  const coins = parseCoins(fieldValue)

  const floatRegex = /^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$/
  const maxAmount = Number.MAX_SAFE_INTEGER

  if (!floatRegex.test(fieldValue) || isNaN(coins)) {
    validationError = {code: 'SendAmountIsNan'}
  } else if (fieldValue.split('.').length === 2 && fieldValue.split('.')[1].length > 6) {
    validationError = {code: 'SendAmountPrecisionLimit'}
  } else if (coins > maxAmount) {
    validationError = {code: 'SendAmountIsTooBig'}
  } else if (coins <= 0) {
    validationError = {code: 'SendAmountIsNotPositive'}
  }

  return {fieldValue, coins, validationError}
}

export const feeValidator = (sendAmount, transactionFee, balance) => {
  let validationError = null

  if (sendAmount + transactionFee > balance) {
    validationError = {
      code: 'SendAmountInsufficientFunds',
      params: {balance},
    }
  }

  return validationError
}

export const mnemonicValidator = async (mnemonic) => {
  let validationError = null

  if (!validateMnemonic(mnemonic) && !(await validatePaperWalletMnemonic(mnemonic))) {
    validationError = {
      code: 'InvalidMnemonic',
    }
  }

  return validationError
}
