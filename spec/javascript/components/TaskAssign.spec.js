import React from 'react'
import { mount } from 'enzyme'
import TaskAssign from 'components/TaskAssign'

describe('TaskAssign', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<TaskAssign />)

    expect(wrapper).toMatchSnapshot()
  })
})
