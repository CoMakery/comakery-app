import React from 'react'
import { mount } from 'enzyme'
import BackButton from 'components/BackButton'

describe('BackButton', () => {
  it('renders component correctly', () => {
    const wrapper = mount(<BackButton />)

    expect(wrapper).toMatchSnapshot()
  })
})
