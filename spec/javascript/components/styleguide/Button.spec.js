import React from 'react'
import { shallow, mount, render } from 'enzyme'
import Button from 'components/styleguide/Button'

describe('Button', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<Button />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.button')).toBe(true)
    expect(wrapper.find('.button').props().value).toBe('publish')
    expect(wrapper.find('.button').props().type).toBe('button')
    expect(wrapper.find('.button').props().disabled).toBe(false)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<Button className="__test" />)

    expect(wrapper.exists('.button.__test')).toBe(true)
  })

  it('renders correctly with custom type', () => {
    const wrapper = shallow(<Button type="file" />)

    expect(wrapper.find('.button').props().type).toBe('file')
  })

  it('renders correctly with custom value', () => {
    const wrapper = shallow(<Button value="save" />)

    expect(wrapper.find('.button').props().value).toBe('save')
  })

  it('renders correctly when disabled', () => {
    const wrapper = shallow(<Button disabled />)

    expect(wrapper.find('.button').props().disabled).toBe(true)
  })
})
