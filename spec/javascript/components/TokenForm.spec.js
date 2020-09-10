import React from 'react'
import { mount } from 'enzyme'
import TokenForm from 'components/TokenForm'

describe('TokenForm', () => {
  beforeEach(() => {
    fetch.resetMocks()
  })

  it('renders correctly without props', () => {
    const wrapper = mount(<TokenForm />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('Layout[title="Create a New Token"]')).toBe(true)
    expect(wrapper.exists('.token-form')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="cancel"]')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="create"]')).toBe(true)
    expect(wrapper.exists('Button[value="create & close"]')).toBe(true)
    expect(wrapper.exists('.token-form--message')).toBe(false)
    expect(wrapper.exists('.token-form--form')).toBe(true)
    expect(wrapper.exists('#token-form--form')).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdownHalfed[title="payment type"][required][name="token[_token_type]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdownHalfed[title="visibility"][required][name="token[unlisted]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldUploadFile[title="token logo"][required][name="token[logo_image]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'input[type="hidden"][name="authenticity_token"]'
    )).toBe(true)
  })

  it('renders correctly with erc token', () => {
    const token = {
      'id'                     : 0,
      'name'                   : 'ERC-TEST',
      '_tokenType'               : 'erc20',
      '_blockchain'      : 'ethereum',
      'contractAddress'        : '0x00',
      'symbol'                 : 'ERCT',
      'decimalPlaces'          : 2,
      'logoUrl'                : '/ERCT.png'
    }
    const wrapper = mount(<TokenForm token={token} />)

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="payment type"][required][name="token[_token_type]"]'
    ).props().value).toBe('erc20')

    expect(wrapper.find(
      'InputFieldHalfed[title="token name"][required][name="token[name]"][placeholder="Bitcoin"]'
    ).props().value).toBe('ERC-TEST')

    expect(wrapper.find(
      'InputFieldUploadFile[title="token logo"][required][name="token[logo_image]"]'
    ).props().imgPreviewUrl).toBe('/ERCT.png')

    expect(wrapper.find(
      'InputFieldHalfed[title="token symbol"][required][readOnly][name="token[symbol]"][placeholder="..."]'
    ).props().value).toBe('ERCT')

    expect(wrapper.find(
      'InputFieldHalfed[title="decimal places"][required][readOnly][name="token[decimal_places]"][placeholder="..."]'
    ).props().value).toBe('2')

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="blockchain network"][required][name="token[_blockchain]"]'
    ).props().value).toBe('ethereum')
  })

  it('renders correctly with qrc token', () => {
    const token = {
      'id'                     : 1,
      'name'                   : 'QRC-TEST',
      '_tokenType'               : 'qrc20',
      '_blockchain'      : 'test',
      'contractAddress'        : '0',
      'symbol'                 : 'QRCT',
      'decimalPlaces'          : 0,
      'logoUrl'                : '/QRCT.png'
    }
    const wrapper = mount(<TokenForm token={token} />)

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="payment type"][required][name="token[_token_type]"]'
    ).props().value).toBe('qrc20')

    expect(wrapper.find(
      'InputFieldHalfed[title="token name"][required][name="token[name]"][placeholder="Bitcoin"]'
    ).props().value).toBe('QRC-TEST')

    expect(wrapper.find(
      'InputFieldUploadFile[title="token logo"][required][name="token[logo_image]"]'
    ).props().imgPreviewUrl).toBe('/QRCT.png')

    expect(wrapper.find(
      'InputFieldHalfed[title="contract address"][required][name="token[contract_address]"][placeholder="2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc"][pattern="[a-fA-F0-9]{40}"]'
    ).props().value).toBe('0')

    expect(wrapper.find(
      'InputFieldHalfed[title="token symbol"][required][readOnly][name="token[symbol]"][placeholder="..."]'
    ).props().value).toBe('QRCT')

    expect(wrapper.find(
      'InputFieldHalfed[title="decimal places"][required][readOnly][name="token[decimal_places]"][placeholder="..."]'
    ).props().value).toBe('0')

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="blockchain network"][required][name="token[_blockchain]"]'
    ).props().value).toBe('test')
  })

  it('renders correctly with eth token', () => {
    const token = {
      'id'                     : 1,
      'name'                   : 'ETH-TEST',
      '_tokenType'               : 'eth',
      '_blockchain'      : 'test',
      'contractAddress'        : null,
      'symbol'                 : null,
      'decimalPlaces'          : null,
      'logoUrl'                : '/ETH.png'
    }
    const wrapper = mount(<TokenForm token={token} />)

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="payment type"][required][name="token[_token_type]"]'
    ).props().value).toBe('eth')

    expect(wrapper.find(
      'InputFieldUploadFile[title="token logo"][required][name="token[logo_image]"]'
    ).props().imgPreviewUrl).toBe('/ETH.png')

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="blockchain network"][required][name="token[_blockchain]"]'
    ).props().value).toBe('test')
  })

  it('renders correctly with tokenTypes', () => {
    const tokenTypes = {
      'ERC20': 'erc20',
      'QRC20': 'qrc20',
      'ETH'  : 'eth'
    }
    const wrapper = mount(<TokenForm tokenTypes={tokenTypes} />)

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="payment type"][required][name="token[_token_type]"]'
    ).props().value).toBe('erc20')

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="payment type"][required][name="token[_token_type]"]'
    ).props().selectEntries).toEqual(Object.entries(tokenTypes))
  })

  it('renders correctly with blockchains', () => {
    const token = {
      'id'                     : 1,
      'name'                   : 'QRC-TEST',
      '_tokenType'               : 'qrc20',
      '_blockchain'      : null,
      'contractAddress'        : '0',
      'symbol'                 : 'QRCT',
      'decimalPlaces'          : 0,
      'logoUrl'                : '/QRCT.png'
    }
    const blockchains = {
      'main QTUM Network': 'qtum_mainnet',
      'test QTUM Network': 'qtum_testnet'
    }
    const wrapper = mount(<TokenForm token={token} blockchains={blockchains} />)

    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="blockchain network"][required][name="token[_blockchain]"]'
    ).props().value).toBe('qtum_mainnet')
    expect(wrapper.find(
      'InputFieldDropdownHalfed[title="blockchain network"][required][name="token[_blockchain]"]'
    ).props().selectEntries).toEqual(Object.entries(blockchains))
  })

  it('renders correctly with csrfToken', () => {
    const wrapper = mount(<TokenForm csrfToken='test' />)

    expect(wrapper.find(
      'input[type="hidden"][name="authenticity_token"]'
    ).props().value).toBe('test')
  })

  it('uses formUrl', () => {
    const wrapper = mount(<TokenForm formUrl='/test' />)

    expect(wrapper.state('formUrl')).toBe('/test')
  })

  it('uses formAction', () => {
    const wrapper = mount(<TokenForm formAction='PUT' />)

    expect(wrapper.state('formAction')).toBe('PUT')
  })

  it('uses urlOnSuccess', () => {
    const wrapper = mount(<TokenForm urlOnSuccess='/test' />)

    expect(wrapper.props().urlOnSuccess).toBe('/test')
  })

  it('displays flash messages', () => {
    const wrapper = mount(<TokenForm />)

    wrapper.setState({
      flashMessages: [
        {
          'severity': 'notice',
          'text'    : 'notice text'
        },
        {
          'severity': 'warning',
          'text'    : 'warning text'
        },
        {
          'severity': 'error',
          'text'    : 'error text'
        }
      ]
    })

    wrapper.update()

    expect(wrapper.exists('Flash')).toBe(true)
  })

  it('displays errors', () => {
    const wrapper = mount(<TokenForm />)

    wrapper.setState({
      errors: {
        'token[_token_type]' : '_token_type error',
        'token[logo_image]': 'logo_image error'
      }
    })

    wrapper.update()

    expect(wrapper.exists(
      'InputFieldDropdownHalfed[errorText="_token_type error"][title="payment type"][required][name="token[_token_type]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldUploadFile[errorText="logo_image error"][title="token logo"][required][name="token[logo_image]"]'
    )).toBe(true)
  })
})
