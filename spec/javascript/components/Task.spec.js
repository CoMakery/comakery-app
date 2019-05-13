import React from 'react'
import { mount } from 'enzyme'
import Task from 'components/Task'

describe('Task', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<Task />)

    expect(wrapper).toMatchSnapshot()
  })
})
