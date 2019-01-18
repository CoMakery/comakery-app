import axios from 'axios'
import bitcoinUtils from 'networks/bitcoin/helpers/utils'

jest.mock('axios')

describe('bitcoin utils #getFee', () => {
  afterEach(() => {
    jest.resetAllMocks()
  })

  it('get fee', async() => {
    const resp = { data: {fastestFee: 30} }
    axios.get.mockResolvedValue(resp)

    const rs = await bitcoinUtils.getFee()
    expect(rs).toEqual(0.0000765)
    expect(axios.get).toHaveBeenCalledTimes(1)
    expect(axios.get).toHaveBeenCalledWith('https://bitcoinfees.earn.com/api/v1/fees/recommended')
  })

  it('get fee with error from axios', async() => {
    axios.get.mockImplementation(() => Promise.reject({error: true}))
    const rs = await bitcoinUtils.getFee()
    expect(rs).toEqual(0.0001)
    expect(axios.get).toHaveBeenCalledTimes(1)
    expect(axios.get).toHaveBeenCalledWith('https://bitcoinfees.earn.com/api/v1/fees/recommended')
  })
})

describe('bitcoin utils #selectTxs', () => {
  const fixtures = require('./fixtures/utils-selectTxs.json')
  const errorsFixtures = require('./fixtures/utils-selectTxs-errors.json')
  fixtures.forEach(({description, unspentTransactions, amount, fee, result}) => {
    it(description, async() => {
      const rs = await bitcoinUtils.selectTxs(unspentTransactions, amount, fee)
      expect(rs).toEqual(result)
    })
  })
  errorsFixtures.forEach(({description, unspentTransactions, amount, fee, error: errorMessage}) => {
    it(description, () => {
      expect(() => {
        bitcoinUtils.selectTxs(unspentTransactions, amount, fee)
      }).toThrowError(errorMessage)
    })
  })
})
