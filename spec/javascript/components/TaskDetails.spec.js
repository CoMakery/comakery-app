import React from 'react'
import { mount } from 'enzyme'
import TaskDetails from 'components/TaskDetails'

describe('TaskDetails', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<TaskDetails />)

    expect(wrapper).toMatchSnapshot()
  })
})
