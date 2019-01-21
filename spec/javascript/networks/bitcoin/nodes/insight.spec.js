import axios from 'axios'
import insight from 'networks/bitcoin/nodes/insight'

jest.mock('axios')

describe('bitcoin insight #getInfo', () => {
  afterEach(() => {
    jest.resetAllMocks()
  })

  describe('on testnet', () => {
    it('get bitcoin account info', async() => {
      const resp = { data: {balance: 0.48933374} }
      axios.get.mockResolvedValue(resp)

      const rs = await insight.getInfo('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 'testnet')
      expect(rs).toEqual(resp.data)
      expect(axios.get).toHaveBeenCalledTimes(1)
      expect(axios.get).toHaveBeenCalledWith('https://test-insight.bitpay.com/api/addr/msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
    })
  })

  describe('on mainnet', () => {
    it('get bitcoin account info', async() => {
      const resp = { data: {balance: 0.48933374} }
      axios.get.mockResolvedValue(resp)

      const rs = await insight.getInfo('msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps', 'mainnet')
      expect(rs).toEqual(resp.data)
      expect(axios.get).toHaveBeenCalledTimes(1)
      expect(axios.get).toHaveBeenCalledWith('https://insight.bitpay.com/api/addr/msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps')
    })
  })
})
