import React from 'react'
import { mount } from 'enzyme'
import Batch from 'components/Batch'

describe('Batch', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<Batch />)

    expect(wrapper).toMatchSnapshot()
  })
})
