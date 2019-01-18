import TrezorConnect from 'trezor-connect'
import trezorUtils from 'networks/bitcoin/trezor_utils'

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
