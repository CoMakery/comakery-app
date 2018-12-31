import React from 'react'
import { shallow } from 'enzyme'
import MessageWarning from 'components/styleguide/MessageWarning'

describe('MessageWarning', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<MessageWarning />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.message__warning')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<MessageWarning className="__test" />)

    expect(wrapper.exists('.message__warning.__test')).toBe(true)
  })
})
