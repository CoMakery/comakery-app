import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldDescriptionMiddle from 'components/styleguide/InputFieldDescriptionMiddle'

describe('InputFieldDescriptionMiddle', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<InputFieldDescriptionMiddle />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.input-field__description-middle')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<InputFieldDescriptionMiddle className="__test" />)

    expect(wrapper.exists('.input-field__description-middle.__test')).toBe(true)
  })
})
