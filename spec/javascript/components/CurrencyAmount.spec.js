import React from 'react'
import { mount } from 'enzyme'
import CurrencyAmount from 'components/CurrencyAmount'

describe('CurrencyAmount', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<CurrencyAmount />)

    expect(wrapper).toMatchSnapshot()
  })
})
