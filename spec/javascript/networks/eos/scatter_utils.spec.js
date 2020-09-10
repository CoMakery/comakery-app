import $ from 'jquery'
import scatterUtils from 'networks/eos/scatter_utils'

describe('eos scatter utils #transferEosCoins', () => {
  const award = {
    'id'                    : 96,
    'total_amount'          : '1.0',
    'issuer_address'        : null,
    'amount_to_send'        : 1,
    'recipient_display_name': 'Vu',
    'account'               : {
      'id'             : 9,
      'ethereum_wallet': '0x7ed37fad1954961819fa08555cf90f6c5b609dc',
      'qtum_wallet'    : 'qSf61RfH28cins3EyiL3BQrGmbqaJUHDf',
      'cardano_wallet' : 'Ae2tdPwUPEZC8obLcka73T3g7WNhb5x1563KdgQyDenoeLbaP9LjHNwsCL',
      'eos_wallet'     : 'aaatestnet11'
    },
    'project': {
      'id': 22
    },
    'award_type': {
      'id': 22
    },
    'token': {
      'id'                       : 1,
      'blockchain_network'         : null,
      '_token_type'                : 'eos',
      'blockchain_network'       : 'eos_testnet',
      'contract_address'         : null
    }
  }

  beforeEach(() => {
    console.error = jest.fn(() => false)
    window.alertMsg = jest.fn(() => false)
    window.foundationCmd = jest.fn(() => false)
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('transfer EOS coins', async() => {
    scatterUtils.__Rewire__('submitTransaction', () => {
      return Promise.resolve('2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df')
    })
    const txId = await scatterUtils.transferEosCoins(award)
    expect(txId).toEqual('2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df')
  })

  it('reject transferring EOS coins', async() => {
    scatterUtils.__Rewire__('submitTransaction', () => {
      return Promise.reject(new Error('rejected'))
    })
    document.body.innerHTML = '<div class="flash-msg" />'
    $('body').addClass('projects-show')
    await scatterUtils.transferEosCoins(award)
  })
})
