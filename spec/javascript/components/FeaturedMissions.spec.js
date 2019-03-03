import React from 'react'
import { mount } from 'enzyme'
import FeaturedMissions from 'components/FeaturedMissions'

describe('FeaturedMissions', () => {
  beforeEach(() => {
    fetch.resetMocks()
  })

  it('renders correctly without props', () => {
    const wrapper = mount(<FeaturedMissions />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.featured-missions__header')).toBe(true)
    expect(wrapper.exists('.featured-missions__content')).toBe(true)
    expect(wrapper.exists('.featured-missions__more')).toBe(true)
    expect(wrapper.exists('.featured-missions__footer')).toBe(true)
  })

  it('grays out page for unconfirmed accounts and disables intercom', () => {
    const wrapper = mount(<FeaturedMissions isConfirmed={false} />)

    expect(wrapper.exists('.grayed-page')).toBe(true)
    expect(wrapper.exists('.intercom')).toBe(false)
  })

  it('renders correctly with props', () => {
    const topMissions = [
      {
        id         : 1,
        name       : 'Mission 1',
        description: 'Description 1',
        imageUrl   : '/logo.png',
        projects   : [
          { id: 1, title: 'Project 1', interested: true },
          { id: 2, title: 'Project 2', interested: false }
        ],
      },
      {
        id         : 2,
        name       : 'Mission 2',
        description: 'Description 2',
        imageUrl   : '/logo.png',
        projects   : [
          { id: 3, title: 'Project 3', interested: true },
          { id: 4, title: 'Project 4', interested: false }
        ],
      }
    ]
    const moreMissions = [
      {
        id           : 3,
        name         : 'Mission 3',
        imageUrl     : '/logo.png',
        projectsCount: 3
      },
      {
        id           : 4,
        name         : 'Mission 4',
        imageUrl     : '/logo.png',
        projectsCount: 2
      },
      {
        id           : 5,
        name         : 'Mission 5',
        imageUrl     : '/logo.png',
        projectsCount: 3
      },
      {
        id           : 6,
        name         : 'Mission 6',
        imageUrl     : '/logo.png',
        projectsCount: 2
      }
    ]

    const wrapper = mount(<FeaturedMissions topMissions={topMissions} moreMissions={moreMissions} />)

    expect(wrapper.exists('FeaturedMission[name="Mission 1"]')).toBe(true)
    expect(wrapper.exists('FeaturedMission[name="Mission 2"]')).toBe(true)
    expect(wrapper.exists('Slider[className="featured-missions__gallery"]')).toBe(true)
  })
})
