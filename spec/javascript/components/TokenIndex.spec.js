import React from 'react'
import { mount } from 'enzyme'
import TokenIndex from 'components/TokenIndex'

describe('TokenIndex', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<TokenIndex />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.token-index')).toBe(true)
    expect(wrapper.exists('.token-index--sidebar')).toBe(true)
    expect(wrapper.exists('.token-index--sidebar SidebarItemBold')).toBe(true)
    expect(wrapper.find('.token-index--sidebar SidebarItemBold').props().iconLeftName).toBe('MARK-WHITE.svg')
    expect(wrapper.find('.token-index--sidebar SidebarItemBold').props().iconRightName).toBe('PLUS.svg')
    expect(wrapper.exists('.token-index--sidebar--info')).toBe(false)
    expect(wrapper.exists('.token-index--view')).toBe(false)
  })

  it('renders correctly with tokens', () => {
    const tokens = [
      {
        'id'                     : 0,
        'name'                   : 'ERC-TEST',
        'TokenType'               : 'erc20',
        'Blockchain'      : 'main',
        'contractAddress': '0x00',
        'symbol'                 : 'ERCT',
        'decimalPlaces'          : 2,
        'logoUrl'                : '/ERCT.png'
      },
      {
        'id'                     : 1,
        'name'                   : 'QRC-TEST',
        'TokenType'               : 'qrc20',
        'Blockchain'      : 'test',
        'contractAddress'        : '0',
        'symbol'                 : 'QRCT',
        'decimalPlaces'          : 0,
        'logoUrl'                : '/QRCT.png'
      }
    ]
    const wrapper = mount(<TokenIndex tokens={tokens} />)

    expect(wrapper.find('.token-index--sidebar--info').text()).toBe('Please select token:')

    expect(wrapper.exists('SidebarItem[iconLeftUrl="/ERCT.png"]')).toBe(true)
    expect(wrapper.exists('SidebarItem[text="ERC-TEST (ERCT)"]')).toBe(true)

    expect(wrapper.exists('SidebarItem[iconLeftUrl="/QRCT.png"]')).toBe(true)
    expect(wrapper.exists('SidebarItem[text="QRC-TEST (QRCT)"]')).toBe(true)
  })

  it('displays correct token details on sidebar item click', () => {
    const tokens = [
      {
        'id'                     : 0,
        'name'                   : 'ERC-TEST',
        'TokenType'               : 'erc20',
        'Blockchain'      : 'main',
        'contractAddress': '0x00',
        'symbol'                 : 'ERCT',
        'decimalPlaces'          : 2,
        'logoUrl'                : '/ERCT.png'
      },
      {
        'id'                     : 1,
        'name'                   : 'QRC-TEST',
        'TokenType'               : 'qrc20',
        'Blockchain'      : 'test',
        'contractAddress'        : 0,
        'symbol'                 : 'QRCT',
        'decimalPlaces'          : 0,
        'logoUrl'                : '/QRCT.png'
      }
    ]
    const wrapper = mount(<TokenIndex tokens={tokens} />)

    expect(wrapper.exists('.token-index--view')).toBe(false)

    wrapper.find('SidebarItem[iconLeftUrl="/ERCT.png"]').simulate('click')
    expect(wrapper.find('.token-index--view').text()).toMatch(/ERC-TEST/)

    wrapper.find('SidebarItem[iconLeftUrl="/QRCT.png"]').simulate('click')
    expect(wrapper.find('.token-index--view').text()).not.toMatch(/ERC-TEST/)
    expect(wrapper.find('.token-index--view').text()).toMatch(/QRC-TEST/)
  })
})
