import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldDropdown from 'components/styleguide/InputFieldDropdown'

describe('InputFieldDropdown', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<InputFieldDropdown />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.find('.input-field__dropdown').props().type).toBe('select')
    expect(wrapper.exists('.input-field--title--counter')).not.toBe()
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<InputFieldDropdown className="__test" />)

    expect(wrapper.exists('.input-field__dropdown.__test')).toBe(true)
  })
})
