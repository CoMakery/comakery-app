import React from 'react'
import { shallow } from 'enzyme'
import SidebarItem from 'components/styleguide/SidebarItem'

describe('SidebarItem', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<SidebarItem />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.sidebar-item')).toBe(true)
    expect(wrapper.exists('.sidebar-item__selected')).toBe(false)
    expect(wrapper.exists('.sidebar-item--wrapper')).toBe(true)
    expect(wrapper.exists('.sidebar-item--icon-left')).toBe(false)
    expect(wrapper.exists('.sidebar-item--text')).toBe(true)
    expect(wrapper.exists('.sidebar-item--icon-right')).toBe(false)
    expect(wrapper.find('.sidebar-item--text').text()).toBe('sidebar item')
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<SidebarItem className="__test" />)

    expect(wrapper.exists('.sidebar-item.__test')).toBe(true)
  })

  it('renders correctly with custom text', () => {
    const wrapper = shallow(<SidebarItem text="test" />)

    expect(wrapper.find('.sidebar-item--text').text()).toBe('test')
  })

  it('renders correctly with custom iconLeftUrl', () => {
    const wrapper = shallow(<SidebarItem iconLeftUrl="/ALERT.svg" />)

    expect(wrapper.exists('.sidebar-item--icon-left img')).toBe(true)
  })

  it('renders correctly with custom iconLeftName', () => {
    const wrapper = shallow(<SidebarItem iconLeftName="ALERT.svg" />)

    expect(wrapper.exists('.sidebar-item--icon-left Icon')).toBe(true)
  })

  it('renders correctly with custom iconRightName', () => {
    const wrapper = shallow(<SidebarItem iconRightName="ALERT.svg" />)

    expect(wrapper.exists('.sidebar-item--icon-right Icon')).toBe(true)
  })

  it('renders correctly when selected', () => {
    const wrapper = shallow(<SidebarItem selected />)

    expect(wrapper.exists('.sidebar-item__selected')).toBe(true)
  })
})
