import axios from 'axios'
import bitcoinUtils from 'networks/bitcoin/helpers/utils'

jest.mock('axios')

describe('bitcoin utils', () => {
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
})
