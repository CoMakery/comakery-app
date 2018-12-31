import React from 'react'
import { shallow } from 'enzyme'
import SidebarItemBold from 'components/styleguide/SidebarItemBold'

describe('SidebarItemBold', () => {
  it('renders correctly without props', () => {
    const wrapper = shallow(<SidebarItemBold />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.sidebar-item__bold')).toBe(true)
  })

  it('renders correctly with custom className', () => {
    const wrapper = shallow(<SidebarItemBold className="__test" />)

    expect(wrapper.exists('.sidebar-item__bold.__test')).toBe(true)
  })
})
