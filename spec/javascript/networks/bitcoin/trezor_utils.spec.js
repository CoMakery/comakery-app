import utils from 'networks/bitcoin/helpers/utils'
import insight from 'networks/bitcoin/nodes/insight'
import trezorUtils from 'networks/bitcoin/trezor_utils'
import TrezorConnect from 'trezor-connect'

describe('bitcoin trezor utils #getFirstBitcoinAddress', () => {
  beforeEach(() => {
    TrezorConnect.getAddress = jest.fn(() => {
      return { payload: {address: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'} }
    })
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  describe('on testnet', () => {
    it('returns standard address', async() => {
      const rs = await trezorUtils.getFirstBitcoinAddress('testnet', false)
      expect(rs).toEqual('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
      expect(TrezorConnect.getAddress).toHaveBeenCalledWith({path: "m/49'/1'/0'/0/0",
        coin: 'test'})
      expect(TrezorConnect.getAddress).toHaveBeenCalledTimes(1)
    })

    it('returns legacy address', async() => {
      const rs = await trezorUtils.getFirstBitcoinAddress('testnet', true)
      expect(rs).toEqual('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
      expect(TrezorConnect.getAddress).toHaveBeenCalledWith({path: "m/44'/1'/0'/0/0",
        coin: 'test'})
      expect(TrezorConnect.getAddress).toHaveBeenCalledTimes(1)
    })
  })

  describe('on mainnet', () => {
    it('returns standard address', async() => {
      const rs = await trezorUtils.getFirstBitcoinAddress('mainnet', false)
      expect(rs).toEqual('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
      expect(TrezorConnect.getAddress).toHaveBeenCalledWith({path: "m/49'/0'/0'/0/0",
        coin: 'btc'})
      expect(TrezorConnect.getAddress).toHaveBeenCalledTimes(1)
    })

    it('returns legacy address', async() => {
      const rs = await trezorUtils.getFirstBitcoinAddress('mainnet', true)
      expect(rs).toEqual('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
      expect(TrezorConnect.getAddress).toHaveBeenCalledWith({path: "m/44'/0'/0'/0/0",
        coin: 'btc'})
      expect(TrezorConnect.getAddress).toHaveBeenCalledTimes(1)
    })
  })
})

describe('bitcoin trezor utils #submitTransaction', () => {
  const amount = 1
  const to = 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'

  beforeEach(() => {
    TrezorConnect.getAddress = jest.fn(() => {
      return { payload: {address: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'} }
    })
    utils.getFee = jest.fn(() => 0.001)
    insight.getInfo = jest.fn(() => {
      return { balance: 2 }
    })
    insight.getUtxoList = jest.fn(() => {
      return [{
        'address'      : 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps',
        'txid'         : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
        'confirmations': 3,
        'amount'       : 2,
        'satoshis'     : 200000000,
        'hash'         : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
        'pos'          : 0
      }]
    })
    utils.selectTxs = jest.fn(() => {
      return [{
        'address'      : 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps',
        'txid'         : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
        'confirmations': 3,
        'amount'       : 2,
        'satoshis'     : 200000000,
        'hash'         : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
        'pos'          : 0
      }]
    })
    TrezorConnect.signTransaction = jest.fn(() => {
      return { success: true, payload: {txid: '2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df'} }
    })
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  describe('on testnet', () => {
    const inputs = [{
      address_n  : [2147483697, 2147483649, 2147483648, 0, 0],
      prev_index : 0,
      prev_hash  : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
      amount     : '200000000',
      script_type: 'SPENDP2SHWITNESS'
    }]
    const outputs = [
      {
        address_n  : [2147483697, 2147483649, 2147483648, 0, 0],
        amount     : `${200000000 - (amount * 1e8 + 0.001 * 1e8)}`,
        script_type: 'PAYTOP2SHWITNESS'
      }, {
        address    : to,
        amount     : '100000000',
        script_type: 'PAYTOADDRESS'
      }
    ]
    it('submit transaction', async() => {
      const txId = await trezorUtils.submitTransaction('testnet', 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', amount)
      expect(txId).toEqual('2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df')
      expect(TrezorConnect.signTransaction).toHaveBeenCalledWith({inputs: inputs, outputs: outputs, coin: 'Testnet', push: true})
    })

    it('throws an error when amount > balance', () => {
      expect(trezorUtils.submitTransaction('testnet', 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 4)).rejects.toThrowError(/You don't have sufficient Tokens to send/)
    })
  })

  describe('on mainnet', () => {
    const inputs = [{
      address_n  : [2147483697, 2147483648, 2147483648, 0, 0],
      prev_index : 0,
      prev_hash  : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
      amount     : '200000000',
      script_type: 'SPENDP2SHWITNESS'
    }]
    const outputs = [
      {
        address_n  : [2147483697, 2147483648, 2147483648, 0, 0],
        amount     : `${200000000 - (amount * 1e8 + 0.001 * 1e8)}`,
        script_type: 'PAYTOP2SHWITNESS'
      }, {
        address    : to,
        amount     : '100000000',
        script_type: 'PAYTOADDRESS'
      }
    ]
    it('submit transaction', async() => {
      const txId = await trezorUtils.submitTransaction('mainnet', 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', amount)
      expect(txId).toEqual('2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df')
      expect(TrezorConnect.signTransaction).toHaveBeenCalledWith({inputs: inputs, outputs: outputs, coin: 'Bitcoin', push: true})
    })

    it('throws an error when amount > balance', () => {
      expect(trezorUtils.submitTransaction('mainnet', 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 4)).rejects.toThrowError(/You don't have sufficient Tokens to send/)
    })
  })
})
