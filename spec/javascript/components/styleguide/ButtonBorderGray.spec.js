import React from 'react'
import { shallow } from 'enzyme'
import ButtonBorderGray from 'components/styleguide/ButtonBorderGray'

describe('ButtonBorderGray', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<ButtonBorderGray />)

    expect(wrapper).toMatchSnapshot()
  })
})
