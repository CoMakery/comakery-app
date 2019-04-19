import React from 'react'
import { mount } from 'enzyme'
import ContentElement from 'components/ContentElement'

describe('ContentElement', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<ContentElement />)

    expect(wrapper).toMatchSnapshot()
  })
})
