import React from 'react'
import { mount } from 'enzyme'
import ContentBlock from 'components/ContentBlock'

describe('ContentBlock', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<ContentBlock />)

    expect(wrapper).toMatchSnapshot()
  })
})
