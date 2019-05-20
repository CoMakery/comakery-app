import React from 'react'
import { mount } from 'enzyme'
import MyTask from 'components/MyTask'

describe('MyTask', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<MyTask />)

    expect(wrapper).toMatchSnapshot()
  })
})
