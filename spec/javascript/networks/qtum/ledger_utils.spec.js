/* eslint-disable */
import $ from 'jquery'
import ledgerUtils from 'networks/qtum/ledger_utils'
//
// Details: https://github.com/CoMakery/comakery-app/pull/1207
//

describe('qtum ledger utils #transferQtumCoins', () => {
  const award = {
    'id'                    : 96,
    'total_amount'          : '1.0',
    'issuer_address'        : null,
    'amount_to_send'        : 1,
    'recipient_display_name': 'Vu',
    'account'               : {
      'id'             : 9,
      'ethereum_wallet': '0x7ed37fad1954961819fa08555cf90f6c5b609dc',
      'qtum_wallet'    : 'qSf61RfH28cins3EyiL3BQrGmbqaJUHDfM',
      'cardano_wallet' : 'Ae2tdPwUPEZC8obLcka73T3g7WNhb5x1563KdgQyDenoeLbaP9LjHNwsCL',
      'bitcoin_wallet' : 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'
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
      'coin_type'                : 'qtum',
      'blockchain_network'       : 'qtum_testnet',
      'contract_address'         : null
    }
  }

  beforeEach(() => {
    console.log = jest.fn(() => false)
    window.alertMsg = jest.fn(() => false)
    window.foundationCmd = jest.fn(() => false)
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('transfer QTUM coins', async() => {
    ledgerUtils.__Rewire__('submitTransaction', () => {
      return Promise.resolve('2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df')
    })
    const txId = await ledgerUtils.transferQtumCoins(award)
    expect(txId).toEqual('2e49b7de8dd07eab030f53348641bd85f3df9f74d93231c62f36231ce2b0b7df')
  })

  it('reject transferring QTUM coins', async() => {
    ledgerUtils.__Rewire__('submitTransaction', () => {
      return Promise.reject(new Error('rejected'))
    })
    document.body.innerHTML = '<div class="flash-msg" />'
    $('body').addClass('projects-show')
    await ledgerUtils.transferQtumCoins(award)
  })
})
