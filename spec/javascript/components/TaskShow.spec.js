import React from 'react'
import { mount } from 'enzyme'
import TaskShow from 'components/TaskShow'

describe('TaskShow', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<TaskShow />)

    expect(wrapper).toMatchSnapshot()

    expect(wrapper.exists('Layout[title]')).toBe(true)
    expect(wrapper.exists('.task-award-form')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="cancel"]')).toBe(true)
    expect(wrapper.exists('Button[value="proceed"]')).toBe(true)
    expect(wrapper.exists('.task-award-form--message')).toBe(false)
    expect(wrapper.exists('.task-award-form--form')).toBe(true)
    expect(wrapper.exists('#task-award-form--form')).toBe(true)

    expect(wrapper.exists(
      'InputFieldDropdown[title="communication channel"][name="task[channel_id]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="email"][required][name="task[email]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescriptionMiddle[title="message"][recommended][name="task[message]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="quantity"][required][name="task[quantity]"]'
    )).toBe(true)

    expect(wrapper.exists(
      '.task-award-form--form--field'
    )).toBe(true)

    expect(wrapper.exists(
      'input[type="hidden"][name="authenticity_token"]'
    )).toBe(true)
  })

  it('renders correctly with channels and members', () => {
    const channels = {
      'general': '1',
      'random' : '2',
      'email'  : ''
    }
    const members = {
      '1': {
        'slackbot - @slackbot': 'USLACKBOT'
      },
      '2': {
        'slackbot - @slackbot': 'USLACKBOT'
      }
    }

    const wrapper = mount(<TaskShow channels={channels} members={members} />)

    expect(wrapper.find(
      'InputFieldDropdown[name="task[channel_id]"]'
    ).props().value).toBe('1')

    expect(wrapper.find(
      'InputFieldDropdown[name="task[channel_id]"]'
    ).props().selectEntries).toEqual(Object.entries(channels))

    expect(wrapper.find(
      'InputFieldDropdown[name="task[uid]"]'
    ).props().selectEntries).toEqual(Object.entries(members['1']))

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="email"][required][name="task[email]"]'
    )).toBe(false)

    wrapper.find(
      'InputFieldDropdown[name="task[channel_id]"]'
    ).simulate('change', {target: {value: '2'}})

    expect(wrapper.find(
      'InputFieldDropdown[name="task[uid]"]'
    ).props().selectEntries).toEqual(Object.entries(members['2']))

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="email"][required][name="task[email]"]'
    )).toBe(false)
  })

  it('calculates total amount', () => {
    const wrapper = mount(<TaskShow />)

    expect(wrapper.find(
      '.task-award-form--form--field'
    ).text()).toBe('total award amount (DMT)100.00000000 × 1 = 100.00000000')
  })

  it('renders correctly with csrfToken', () => {
    const wrapper = mount(<TaskShow csrfToken="test" />)

    expect(wrapper.find(
      'input[type="hidden"][name="authenticity_token"]'
    ).props().value).toBe('test')
  })

  it('uses formUrl', () => {
    const wrapper = mount(<TaskShow formUrl="/test" />)

    expect(wrapper.state('formUrl')).toBe('/test')
  })

  it('uses formAction', () => {
    const wrapper = mount(<TaskShow formAction="PUT" />)

    expect(wrapper.state('formAction')).toBe('PUT')
  })

  it('uses urlOnSuccess', () => {
    const wrapper = mount(<TaskShow urlOnSuccess="/test" />)

    expect(wrapper.props().urlOnSuccess).toBe('/test')
  })

  it('displays messages', () => {
    const wrapper = mount(<TaskShow />)

    wrapper.setState({
      flashMessages: [
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
        },
      ]
    })

    wrapper.update()

    expect(wrapper.exists('Flash')).toBe(true)
  })

  it('displays errors', () => {
    const wrapper = mount(<TaskShow />)

    wrapper.setState({
      errors: {
        'task[channel_id]': 'channel_id error',
        'task[message]'   : 'message error',
      }
    })

    wrapper.update()

    expect(wrapper.exists(
      'InputFieldDropdown[errorText="channel_id error"][name="task[channel_id]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescriptionMiddle[errorText="message error"][name="task[message]"]'
    )).toBe(true)
  })
})
