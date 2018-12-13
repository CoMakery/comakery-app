import React from 'react'
import { shallow, mount, render } from 'enzyme'
import ButtonPrimaryDisabled from 'components/styleguide/ButtonPrimaryDisabled'

describe('ButtonPrimaryDisabled', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<ButtonPrimaryDisabled/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.exists('.button__primary__disabled')).toBe(true)
      expect(wrapper.find('.button__primary__disabled').props().disabled).toBe(true)
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<ButtonPrimaryDisabled className='__test' />)

      expect(wrapper.exists('.button__primary__disabled.__test')).toBe(true)
    })
})
