import React from 'react'
import { shallow } from 'enzyme'
import InputFieldDescription from 'components/styleguide/InputFieldDescription'

describe('InputFieldDescription', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<InputFieldDescription />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.input-field__description')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<InputFieldDescription className="__test" />)

    expect(wrapper.exists('.input-field__description.__test')).toBe(true)
  })
})
