import React from 'react'
import { mount } from 'enzyme'
import FeaturedMission from 'components/FeaturedMission'

describe('FeaturedMission', () => {
  beforeEach(() => {
    fetch.resetMocks()
  })

  it('renders correctly without props', () => {
    const wrapper = mount(<FeaturedMission />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.featured-mission')).toBe(true)
    expect(wrapper.exists('.featured-mission__image')).toBe(true)
    expect(wrapper.exists('.featured-mission__detail')).toBe(true)
    expect(wrapper.exists('.featured-mission__name')).toBe(true)
    expect(wrapper.exists('.featured-mission__description')).toBe(true)
  })

  it('renders correctly with props', () => {
    const mission = {
      float      : 'right',
      name       : 'Test Mission Name',
      description: 'This is test mission',
      imageUrl   : '/logo.png',
      projects   : [
        { id: 1, title: 'Project 1', interested: true },
        { id: 2, title: 'Project 2', interested: false }
      ],
      csrfToken: '00'
    }

    const wrapper = mount(<FeaturedMission {...mission} />)

    expect(wrapper.exists('.featured-mission--right')).toBe(true)
    expect(wrapper.find('.featured-mission__image').find('img').prop('src')).toEqual('/logo.png')
    expect(wrapper.find('.featured-mission__name').text()).toEqual('Test Mission Name')
    expect(wrapper.find('.featured-mission__description').text()).toEqual('This is test mission')
    expect(wrapper.find('.featured-mission__project').first().find('.featured-mission__project__title').text()).toEqual('Project 1')
    expect(wrapper.find('.featured-mission__project').first().find('.featured-mission__project__interest').text()).toEqual('Unfollow')
    expect(wrapper.find('.featured-mission__project').last().find('.featured-mission__project__title').text()).toEqual('Project 2')
    expect(wrapper.find('.featured-mission__project').last().find('.featured-mission__project__interest').text()).toEqual('Follow')
  })

  it('updates project-interest', () => {
    const mission = {
      float      : 'right',
      name       : 'Test Mission Name',
      description: 'This is test mission',
      imageUrl   : '/logo.png',
      projects   : [
        { id: 1, title: 'Project 1', interested: true },
        { id: 2, title: 'Project 2', interested: false }
      ],
      csrfToken: '00'
    }

    const wrapper = mount(<FeaturedMission {...mission} />)
    wrapper.setState({
      projects: [
        { id: 1, title: 'Project 1', interested: true },
        { id: 2, title: 'Project 2', interested: true }
      ]
    })

    wrapper.update()
    expect(wrapper.find('.featured-mission__project').first().find('.featured-mission__project__title').text()).toEqual('Project 1')
    expect(wrapper.find('.featured-mission__project').first().find('.featured-mission__project__interest').text()).toEqual('Unfollow')
    expect(wrapper.find('.featured-mission__project').last().find('.featured-mission__project__title').text()).toEqual('Project 2')
    expect(wrapper.find('.featured-mission__project').last().find('.featured-mission__project__interest').text()).toEqual('Unfollow')
  })
})
