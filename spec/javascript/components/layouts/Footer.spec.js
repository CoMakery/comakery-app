import React from 'react'
import { shallow } from 'enzyme'
import Footer from 'components/layouts/Footer'

describe('Footer', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<Footer />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.footer')).toBe(true)
    expect(wrapper.exists('.footer--logo')).toBe(true)
    expect(wrapper.exists('.footer--content')).toBe(true)
    expect(wrapper.exists('.footer--content--text')).toBe(true)
    expect(wrapper.exists('.footer--content--nav')).toBe(true)
    expect(wrapper.exists('.footer--content--nav--about')).toBe(true)
    expect(wrapper.exists('.footer--content--nav--join')).toBe(true)
    expect(wrapper.exists('.footer--content--nav--legal')).toBe(true)
    expect(wrapper.exists('.footer--copyright')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<Footer className="__test" />)

    expect(wrapper.exists('.footer.__test')).toBe(true)
  })

  it('renders correctly with loggedIn flag', () => {
    const wrapper = shallow(<Footer isLoggedIn />)

    expect(wrapper.exists('.footer--content--nav--join')).toBe(false)
  })
})
