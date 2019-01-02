import React from 'react'
import { shallow } from 'enzyme'
import Icon from 'components/styleguide/Icon'

describe('Icon', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<Icon />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.icon')).toBe(true)
    expect(wrapper.exists('.icon__atomsIconsSystemHeart-svg')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<Icon className="__test" />)

    expect(wrapper.exists('.icon.__test')).toBe(true)
  })

  it('renders correctly with custom name', () => {
    const wrapper = shallow(<Icon name="iconDone.svg" />)

    expect(wrapper.exists('.icon__iconDone-svg')).toBe(true)
  })
})
