import React from 'react'
import { mount } from 'enzyme'
import Flash from 'components/layouts/Flash'

describe('Flash', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<Flash />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.flash-message-container')).toBe(true)
    expect(wrapper.exists('.flash-message')).toBe(true)
    expect(wrapper.exists('.flash-message__icon')).toBe(true)
    expect(wrapper.exists('.flash-message__icon--close')).toBe(true)
  })

  it('renders correctly with several messages', () => {
    const messages = [
      {
        'severity': 'notice',
        'text'    : 'notice text'
      },
      {
        'severity': 'warning',
        'text'    : 'warning text'
      },
      {
        'severity': 'error',
        'text'    : 'error text'
      }
    ]
    const wrapper = mount(<Flash messages={messages} />)

    expect(wrapper.exists('.flash-message--notice')).toBe(true)
    expect(wrapper.find('.flash-message--notice').html()).toContain('notice text')
    expect(wrapper.exists('.flash-message--warning')).toBe(true)
    expect(wrapper.find('.flash-message--warning').html()).toContain('warning text')
    expect(wrapper.exists('.flash-message--error')).toBe(true)
    expect(wrapper.find('.flash-message--error').html()).toContain('error text')
  })

  it('closes message on click', () => {
    const messages = [
      {
        'severity': 'notice',
        'text'    : 'notice text'
      },
      {
        'severity': 'warning',
        'text'    : 'warning text'
      },
      {
        'severity': 'error',
        'text'    : 'error text'
      }
    ]
    const wrapper = mount(<Flash messages={messages} />)

    wrapper.find('.flash-message--warning > .flash-message__icon--close').simulate('click')
    expect(wrapper.exists('.flash-message--warning')).toBe(false)
  })
})
