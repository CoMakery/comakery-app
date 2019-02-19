import React from 'react'
import { shallow } from 'enzyme'
import Flash from 'components/layouts/Flash'

describe('Flash', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<Flash />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.flash-message')).toBe(true)
    expect(wrapper.exists('.flash-message__icon')).toBe(true)
    expect(wrapper.exists('.flash-message__icon--close')).toBe(true)
  })

  it('renders correctly with notice flashType prop', () => {
    const wrapper = shallow(<Flash flashType="notice" />)

    expect(wrapper.exists('.flash-message--notice')).toBe(true)
  })

  it('renders correctly with error flashType prop', () => {
    const wrapper = shallow(<Flash flashType="error" />)

    expect(wrapper.exists('.flash-message--error')).toBe(true)
  })

  it('renders correctly with message prop', () => {
    const wrapper = shallow(<Flash flashType="notice" message="Test Message" />)

    expect(wrapper.exists('.flash-message--notice')).toBe(true)
    expect(wrapper.find('.flash-message').text()).toBe('<Icon />Test Message<Icon />')
  })
})
