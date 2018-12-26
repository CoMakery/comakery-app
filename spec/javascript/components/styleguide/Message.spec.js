import React from 'react'
import { shallow, mount, render } from 'enzyme'
import Message from 'components/styleguide/Message'

describe('Message', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<Message/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.exists('.message')).toBe(true)
      expect(wrapper.exists('.message--icon')).toBe(true)
      expect(wrapper.exists('.message--text__warning')).toBe(true)
      expect(wrapper.exists('.message--close-icon')).toBe(true)
      expect(wrapper.find('.message--text__warning').text()).toBe('warning text')
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<Message className='__test' />)

      expect(wrapper.exists('.message.__test')).toBe(true)
    })

    it('renders correctly with custom severity', () => {
      const wrapper = shallow(<Message severity='error' />)

      expect(wrapper.exists('.message--text__error')).toBe(true)
    })

    it('renders correctly with custom text', () => {
      const wrapper = shallow(<Message text='test' />)

      expect(wrapper.find('.message--text__warning').text()).toBe('test')
    })

    it('gets hidden on close click', () => {
      const wrapper = shallow(<Message/>)

      wrapper.find('.message').find('.message--close-icon').simulate("click")
      expect(wrapper.exists('.message')).toBe(false)
    })
})
