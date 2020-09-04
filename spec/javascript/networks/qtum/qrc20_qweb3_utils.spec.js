import $ from 'jquery'
import qrc20Qweb3Utils from 'networks/qtum/qrc20_qweb3_utils'

describe('qweb3 utils #transferQrc20Tokens', () => {
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
    'token': {
      'id'                       : 1,
      'coin_type'                : 'qrc20',
      'blockchain_network'       : 'qtum_testnet',
      'contract_address'         : 'ed37fad1954961819fa08555cf90f6c5b60d'
    }
  }

  beforeEach(() => {
    window.alertMsg = jest.fn(() => false)
    window.qrypto = jest.fn(() => {
      return { account: {} }
    })
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('reject transferring when not logged in Qrypto', async() => {
    window.qrypto.account = jest.fn(() => {
      return { loggedIn: false }
    })
    document.body.innerHTML = '<div class="flash-msg" />'
    $('body').addClass('projects-show')
    await qrc20Qweb3Utils.transferQrc20Tokens(award)
    expect($('.flash-msg').text()).toMatch('The tokens have been awarded but not transferred because you are not logged in to the Qrypto wallet browser extension. You can transfer tokens on the blockchain with Qrypto')
  })
})
