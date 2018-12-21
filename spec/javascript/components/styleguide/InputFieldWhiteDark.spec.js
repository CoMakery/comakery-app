import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldWhiteDark from 'components/styleguide/InputFieldWhiteDark'

describe('InputFieldWhiteDark', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<InputFieldWhiteDark />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.find('.input-field__white__dark').props().type).toBe('text')
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<InputFieldWhiteDark className="__test" />)

    expect(wrapper.exists('.input-field__white__dark.__test')).toBe(true)
  })
})
