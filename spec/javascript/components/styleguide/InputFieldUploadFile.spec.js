import React from 'react'
import { shallow, mount, render } from 'enzyme'
import InputFieldUploadFile from 'components/styleguide/InputFieldUploadFile'

describe('InputFieldUploadFile', () => {
    it('renders correctly without props', () => {
      const wrapper = shallow(<InputFieldUploadFile/>)

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.find('.input-field__upload-file').props().type).toBe('file')
      expect(wrapper.exists('.input-field--title--counter')).not.toBe()
    })

    it('renders correctly with custom className', () => {
      const wrapper = shallow(<InputFieldUploadFile className='__test' />)

      expect(wrapper.exists('.input-field__upload-file.__test')).toBe(true)
    })
})
