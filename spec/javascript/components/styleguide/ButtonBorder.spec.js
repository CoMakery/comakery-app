import React from 'react'
import { shallow } from 'enzyme'
import ButtonBorder from 'components/styleguide/ButtonBorder'

describe('ButtonBorder', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<ButtonBorder />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.button__border')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<ButtonBorder className="__test" />)

    expect(wrapper.exists('.button__border.__test')).toBe(true)
  })
})
