import React from 'react'
import { shallow, mount, render } from 'enzyme'
import Footer from 'components/layouts/Footer'

describe('Footer', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<Footer/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.exists('.footer')).toBe(true)
      expect(wrapper.exists('.footer--logo')).toBe(true)
      expect(wrapper.exists('.footer--content')).toBe(true)
      expect(wrapper.exists('.footer--content--text')).toBe(true)
      expect(wrapper.exists('.footer--content--nav')).toBe(true)
      expect(wrapper.exists('.footer--copyright')).toBe(true)
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<Footer className='__test' />)

      expect(wrapper.exists('.footer.__test')).toBe(true)
    })
})
