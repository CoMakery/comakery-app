import React from 'react'
import { shallow } from 'enzyme'
import Layout from 'components/layouts/Layout'

describe('Layout', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<Layout />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.layout')).toBe(true)
    expect(wrapper.exists('.layout--back-button')).toBe(false)
    expect(wrapper.exists('.layout--content')).toBe(true)
    expect(wrapper.exists('.layout--content--title')).toBe(true)
    expect(wrapper.exists('.layout--content--sidebar')).toBe(false)
    expect(wrapper.exists('.layout--content--content')).toBe(true)
    expect(wrapper.exists('.layout--content--content__sidebared')).toBe(false)
    expect(wrapper.exists('.layout--subfooter')).toBe(false)
  })

  it('renders correctly with custom title', () => {
    const wrapper = shallow(<Layout title="test" />)

    expect(wrapper.find('.layout--content--title').text()).toBe('test')
  })

  it('renders correctly with custom child', () => {
    const wrapper = shallow(<Layout><p>test</p></Layout>)

    expect(wrapper.find('.layout--content--content p').text()).toBe('test')
  })

  it('renders correctly with custom sidebar', () => {
    const wrapper = shallow(<Layout sidebar={<p>test</p>} />)

    expect(wrapper.find('.layout--content--sidebar p').text()).toBe('test')
    expect(wrapper.exists('.layout--content--content')).toBe(false)
    expect(wrapper.exists('.layout--content--content__sidebared')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<Layout className="__test" />)

    expect(wrapper.exists('.layout.__test')).toBe(true)
  })

  it('renders correctly with back button', () => {
    const wrapper = shallow(<Layout hasBackButton />)

    expect(wrapper.exists('.layout--back-button')).toBe(true)
  })
})
