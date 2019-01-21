import React from 'react'
import { mount } from 'enzyme'
import MissionIndex from 'components/MissionIndex'

describe('MissionIndex', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<MissionIndex />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.mission-index')).toBe(true)
    expect(wrapper.exists('.mission-index--sidebar')).toBe(true)
    expect(wrapper.exists('.mission-index--sidebar SidebarItemBold')).toBe(true)
    expect(wrapper.find('.mission-index--sidebar SidebarItemBold').props().iconLeftName).toBe('MISSION/WHITE.svg')
    expect(wrapper.find('.mission-index--sidebar SidebarItemBold').props().iconRightName).toBe('PLUS.svg')
    expect(wrapper.exists('.mission-index--sidebar--info')).toBe(false)
    expect(wrapper.exists('.mission-index--view')).toBe(false)
  })

  it('renders correctly with missions', () => {
    const missions = [
      {
        'id'          : '0',
        'name'        : 'Mission1',
        'tokenId'     : '1',
        'subtitle'    : 'Title1',
        'description' : 'Description1',
        'status'      : 'active',
        'displayOrder': 1,
        'logoPreview' : '/logo1.png',
        'imagePreview': '/image1.png',
        'tokenName'   : 'test1',
        'tokenSymbol' : 'SYM1',
        'projects'    : []
      },
      {
        'id'          : '1',
        'name'        : 'Mission2',
        'tokenId'     : '2',
        'subtitle'    : 'Title2',
        'description' : 'Description2',
        'status'      : 'passive',
        'displayOrder': 2,
        'logoPreview' : '/logo2.png',
        'imagePreview': '/image2.png',
        'tokenName'   : 'test2',
        'tokenSymbol' : 'SYM2',
        'projects'    : [
          {
            'id'    : 1,
            'title' : 'project1',
            'status': 'active'
          },
          {
            'id'    : 2,
            'title' : 'project2',
            'status': 'passive'
          },
        ]
      },
    ]
    const wrapper = mount(<MissionIndex missions={missions} />)

    expect(wrapper.find('.mission-index--sidebar--info').text()).toBe('Please select or rearrange missions you want to display on landing page:')

    expect(wrapper.exists('SidebarItem[iconRightName="REARRANGE.svg"]')).toBe(true)
    expect(wrapper.exists('SidebarItem[text="Create a Mission"]')).toBe(true)

    expect(wrapper.exists('SidebarItem[text="Mission1"]')).toBe(true)
    expect(wrapper.find('SidebarItem[text="Mission1"]').exists('InputField[type="checkbox"][checked]')).toBe(true)

    expect(wrapper.exists('SidebarItem[text="Mission2"]')).toBe(true)
    expect(wrapper.find('SidebarItem[text="Mission2"]').exists('InputField[type="checkbox"][checked=false]')).toBe(true)
  })

  it('displays correct mission details on sidebar item click', () => {
    const missions = [
      {
        'id'          : '0',
        'name'        : 'Mission1',
        'tokenId'     : '1',
        'subtitle'    : 'Title1',
        'description' : 'Description1',
        'status'      : 'active',
        'displayOrder': 1,
        'logoPreview' : '/logo1.png',
        'imagePreview': '/image1.png',
        'tokenName'   : 'test1',
        'tokenSymbol' : 'SYM1',
        'projects'    : []
      },
      {
        'id'          : '1',
        'name'        : 'Mission2',
        'tokenId'     : '2',
        'subtitle'    : 'Title2',
        'description' : 'Description2',
        'status'      : 'passive',
        'displayOrder': 2,
        'logoPreview' : '/logo2.png',
        'imagePreview': '/image2.png',
        'tokenName'   : 'test2',
        'tokenSymbol' : 'SYM2',
        'projects'    : [
          {
            'id'    : 1,
            'title' : 'project1',
            'status': 'active'
          },
          {
            'id'    : 2,
            'title' : 'project2',
            'status': 'passive'
          },
        ]
      },
    ]
    const wrapper = mount(<MissionIndex missions={missions} />)

    expect(wrapper.exists('.mission-index--view')).toBe(false)

    wrapper.find('SidebarItem[text="Mission1"]').simulate('click')
    expect(wrapper.find('.mission-index--view').text()).toMatch(/Mission1/)
    expect(wrapper.exists('.mission-index--projects')).toBe(false)

    wrapper.find('SidebarItem[text="Mission2"]').simulate('click')
    expect(wrapper.find('.mission-index--view').text()).not.toMatch(/Mission1/)
    expect(wrapper.find('.mission-index--view').text()).toMatch(/Mission2/)
    expect(wrapper.exists('.mission-index--projects')).toBe(true)
    expect(wrapper.find('.mission-index--project-single--left').first().exists('InputField[type="checkbox"][checked]')).toBe(true)
    expect(wrapper.find('.mission-index--project-single--left').last().exists('InputField[type="checkbox"][checked=false]')).toBe(true)
  })
})
