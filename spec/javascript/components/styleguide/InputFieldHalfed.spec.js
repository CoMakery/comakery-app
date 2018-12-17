import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldHalfed from 'components/styleguide/InputFieldHalfed'

describe('InputFieldHalfed', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<InputFieldHalfed/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.find('.input-field__halfed').props().type).toBe('text')
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<InputFieldHalfed className='__test' />)

      expect(wrapper.exists('.input-field__halfed.__test')).toBe(true)
    })
})
