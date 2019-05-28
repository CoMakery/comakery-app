import React from 'react'
import { mount } from 'enzyme'
import MyTasks from 'components/MyTasks'

describe('MyTasks', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<MyTasks />)

    expect(wrapper).toMatchSnapshot()
  })
})
