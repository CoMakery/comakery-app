import React from 'react'
import { mount } from 'enzyme'
import ProjectForm from 'components/ProjectForm'

describe('ProjectForm', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<ProjectForm />)

    expect(wrapper).toMatchSnapshot()
  })
})
