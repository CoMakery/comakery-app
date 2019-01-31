import axios from 'axios'
import insight from 'networks/bitcoin/nodes/insight'

jest.mock('axios')

describe('bitcoin insight #getInfo', () => {
  const resp = { data: {
    address         : 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps',
    balance         : 48933374,
    confirmedBalance: 48933374
  }
  }
  const result = {
    address         : 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps',
    balance         : 0.48933374,
    balanceSat      : 48933374,
    confirmedBalance: 48933374
  }
  afterEach(() => {
    jest.resetAllMocks()
  })

  describe('on testnet', () => {
    it('get bitcoin account info', async() => {
      axios.get.mockResolvedValue(resp)

      const rs = await insight.getInfo('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 'testnet')
      expect(rs).toEqual(result)
      expect(axios.get).toHaveBeenCalledTimes(1)
      expect(axios.get).toHaveBeenCalledWith('https://test.bitgo.com/api/v1/address/msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
    })
  })

  describe('on mainnet', () => {
    it('get bitcoin account info', async() => {
      axios.get.mockResolvedValue(resp)

      const rs = await insight.getInfo('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 'mainnet')
      expect(rs).toEqual(result)
      expect(axios.get).toHaveBeenCalledTimes(1)
      expect(axios.get).toHaveBeenCalledWith('https://www.bitgo.com/api/v1/address/msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
    })
  })
})

describe('bitcoin insight #getUtxoList', () => {
  const utxo = {
    'address'      : 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps',
    'confirmations': 3,
    'value'        : 200000000,
    'tx_hash'      : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
    'tx_output_n'  : 0
  }
  const result = {
    'address'      : 'msb16hf6ssyYkAJ8xqKUjmBEkbW3cWCdps',
    'txid'         : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
    'confirmations': 3,
    'amount'       : 2,
    'satoshis'     : 200000000,
    'hash'         : '1e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7de',
    'pos'          : 0
  }
  afterEach(() => {
    jest.resetAllMocks()
  })

  describe('on testnet', () => {
    it('get bitcoin utxos', async() => {
      const resp = { data: {unspents: [utxo]} }
      axios.get.mockResolvedValue(resp)

      const rs = await insight.getUtxoList('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 'testnet')
      expect(rs).toEqual([result])
      expect(axios.get).toHaveBeenCalledTimes(1)
      expect(axios.get).toHaveBeenCalledWith('https://test.bitgo.com/api/v1/address/msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps/unspents')
    })
  })

  describe('on mainnet', () => {
    it('get bitcoin utxos', async() => {
      const resp = { data: {unspents: [utxo]} }
      axios.get.mockResolvedValue(resp)

      const rs = await insight.getUtxoList('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 'mainnet')
      expect(rs).toEqual([result])
      expect(axios.get).toHaveBeenCalledTimes(1)
      expect(axios.get).toHaveBeenCalledWith('https://www.bitgo.com/api/v1/address/msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps/unspents')
    })
  })
})
