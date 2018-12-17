import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldDropdownHalfed from 'components/styleguide/InputFieldDropdownHalfed'

describe('InputFieldDropdownHalfed', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<InputFieldDropdownHalfed/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.find('.input-field__dropdown--halfed').props().type).toBe('select')
      expect(wrapper.exists('.input-field--title--counter')).not.toBe()
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<InputFieldDropdownHalfed className='__test' />)

      expect(wrapper.exists('.input-field__dropdown--halfed.__test')).toBe(true)
    })
})
