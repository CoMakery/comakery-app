import React from 'react'
import { mount } from 'enzyme'
import Userpics from 'components/Userpics'

describe('Userpics', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<Userpics />)

    expect(wrapper).toMatchSnapshot()
  })
})
