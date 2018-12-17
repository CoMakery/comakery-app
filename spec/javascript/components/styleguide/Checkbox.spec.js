import React from 'react'
import { shallow, mount, render } from 'enzyme'
import Checkbox from 'components/styleguide/Checkbox'

describe('InputFieldUploadFile', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<Checkbox/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.find('.checkbox').props().type).toBe('checkbox')
      expect(wrapper.exists('.input-field--title--counter')).not.toBe()
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<Checkbox className='__test' />)

      expect(wrapper.exists('.checkbox.__test')).toBe(true)
    })
})
