import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldDefined from 'components/styleguide/InputFieldDefined'

describe('InputFieldDefined', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<InputFieldDefined/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.find('.input-field__defined').props().type).toBe('defined')
      expect(wrapper.exists('.input-field--title--counter')).not.toBe()
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<InputFieldDefined className='__test' />)

      expect(wrapper.exists('.input-field__defined.__test')).toBe(true)
    })
})
