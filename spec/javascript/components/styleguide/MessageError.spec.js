import React from 'react'
import { shallow } from 'enzyme'
import MessageError from 'components/styleguide/MessageError'

describe('MessageError', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<MessageError />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.message__error')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<MessageError className="__test" />)

    expect(wrapper.exists('.message__error.__test')).toBe(true)
  })
})
