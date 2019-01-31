import React from 'react'
import { shallow } from 'enzyme'
import ButtonPrimaryEnabled from 'components/styleguide/ButtonPrimaryEnabled'

describe('ButtonPrimaryEnabled', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<ButtonPrimaryEnabled />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.button__primary__enabled')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<ButtonPrimaryEnabled className="__test" />)

    expect(wrapper.exists('.button__primary__enabled.__test')).toBe(true)
  })
})
