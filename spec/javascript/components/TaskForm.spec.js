import React from 'react'
import { mount } from 'enzyme'
import TaskForm from 'components/TaskForm'

describe('TaskForm', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<TaskForm />)

    expect(wrapper).toMatchSnapshot()

    expect(wrapper.exists('Layout[navTitle]')).toBe(true)
    expect(wrapper.exists('.task-form')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="cancel"]')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="create"]')).toBe(true)
    expect(wrapper.exists('Button[value="create & close"]')).toBe(true)
    expect(wrapper.exists('.task-form--message')).toBe(false)
    expect(wrapper.exists('.task-form--form')).toBe(true)
    expect(wrapper.exists('#task-form--form')).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="name"][required][name="task[name]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescriptionMiddle[title="why"][required][name="task[why]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescriptionMiddle[title="description"][required][name="task[description]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescription[title="acceptance requirements"][required][name="task[requirements]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="award amount (undefined)"][required][name="task[amount]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="where to submit completed work"][required][name="task[proof_link]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'input[type="hidden"][name="authenticity_token"]'
    )).toBe(true)
  })

  it('renders correctly with a task and token', () => {
    const task = {
      'id'          : 28,
      'description' : 'Task description',
      'awardTypeId' : 10,
      'proofLink'   : 'http://nowhere',
      'name'        : 'Task name',
      'why'         : 'Task why',
      'requirements': 'Task requirements',
      'amount'      : '100.0',
    }
    const token = {
      'symbol'       : 'DMT',
      'decimalPlaces': 8,
    }

    const wrapper = mount(<TaskForm
      task={task}
      token={token}
    />)

    expect(wrapper.find(
      'InputFieldWhiteDark[title="name"][required][name="task[name]"]'
    ).props().value).toBe('Task name')

    expect(wrapper.find(
      'InputFieldDescriptionMiddle[title="why"][required][name="task[why]"]'
    ).props().value).toBe('Task why')

    expect(wrapper.find(
      'InputFieldDescriptionMiddle[title="description"][required][name="task[description]"]'
    ).props().value).toBe('Task description')

    expect(wrapper.find(
      'InputFieldDescription[title="acceptance requirements"][required][name="task[requirements]"]'
    ).props().value).toBe('Task requirements')

    expect(wrapper.find(
      'InputFieldWhiteDark[title="award amount (DMT)"][required][name="task[amount]"]'
    ).props().value).toBe('100.0')

    expect(wrapper.find(
      'InputFieldWhiteDark[title="where to submit completed work"][required][name="task[proof_link]"]'
    ).props().value).toBe('http://nowhere')
  })

  it('renders correctly with csrfToken', () => {
    const wrapper = mount(<TaskForm csrfToken="test" />)

    expect(wrapper.find(
      'input[type="hidden"][name="authenticity_token"]'
    ).props().value).toBe('test')
  })

  it('uses formUrl', () => {
    const wrapper = mount(<TaskForm formUrl="/test" />)

    expect(wrapper.state('formUrl')).toBe('/test')
  })

  it('uses formAction', () => {
    const wrapper = mount(<TaskForm formAction="PUT" />)

    expect(wrapper.state('formAction')).toBe('PUT')
  })

  it('uses urlOnSuccess', () => {
    const wrapper = mount(<TaskForm urlOnSuccess="/test" />)

    expect(wrapper.props().urlOnSuccess).toBe('/test')
  })

  it('displays messages', () => {
    const wrapper = mount(<TaskForm />)

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
    const wrapper = mount(<TaskForm />)

    wrapper.setState({
      errors: {
        'task[name]'       : 'name error',
        'task[description]': 'description error',
      }
    })

    wrapper.update()

    expect(wrapper.exists(
      'InputFieldWhiteDark[errorText="name error"][title="name"][required][name="task[name]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescriptionMiddle[errorText="description error"][title="description"][required][name="task[description]"]'
    )).toBe(true)
  })
})
