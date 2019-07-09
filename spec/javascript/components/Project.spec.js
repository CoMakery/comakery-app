import React from 'react'
import { mount } from 'enzyme'
import Project from 'components/Project'

describe('Project', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<Project />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.project-container')).toBe(true)
    expect(wrapper.exists('.project-header')).toBe(true)
    expect(wrapper.exists('.project-award')).toBe(true)
    expect(wrapper.exists('.project-description')).toBe(true)
    expect(wrapper.exists('.project-interest')).toBe(true)
    expect(wrapper.exists('.project-team')).toBe(true)
  })

  it('renders correctly with props', () => {
    const props = {
      interested : true,
      projectData: {
        id               : 1,
        title            : 'Core Network',
        descriptionHeader: 'The last social network',
        descriptionHtml  : '<b>Test</b>',
        imageUrl         : null,
        youtubeUrl       : 'hBm5M4u2jLs',
        defaultImageUrl  : 'test.jpg',
        owner            : 'Test User',
        tokenPercentage  : '0.0788',
        maximumTokens    : '10,000,000',
        awardedTokens    : '7,880',
        teamLeader       : {
          id       : 1,
          firstName: 'User Leader',
          nickname : 'Nickname Leader', imageUrl : 'leader_image.jpg',
          specialty: 'Community Development'
        },
        contributorsNumber: 4,
        contributors      : [
          {id: 1, firstName: 'Contributor 1', nickname: 'Nickname 1', imageUrl: 'contributor1.jpg', specialty: 'Community Development'},
          {id: 2, firstName: 'Contributor 2', nickname: 'Nickname 2', imageUrl: 'contributor2.jpg', specialty: 'UI/UX Design'},
          {id: 3, firstName: 'Contributor 3', nickname: 'Nickname 3', imageUrl: 'contributor3.jpg', specialty: 'Researcher'},
          {id: 4, firstName: 'Contributor 4', nickname: 'Nickname 4', imageUrl: 'contributor4.jpg', specialty: 'Community Development'}
        ],
        chartData: [4500, 2260, 1020, 100],
        stats: {}
      },
      missionData: {id: 1, name: 'First Mission', imageUrl: 'mission1.jpg', missionUrl: '/missions/1'},
      tokenData  : {
        name       : 'Ether', coinType   : 'eth', symbol     : 'HOT', imageUrl   : 'token.png', contractUrl: 'https://etherscan.io/token/0x9d3d4cc1986d81f9109f2b091b7732e7d9bcf63b'
      },
      csrfToken       : 'W0fVUAN/GMhmQ7lhD7HNGVAZdHMTIkbdnNDwrIRtxEnGcn0jbtVEn/+gPj9jp5jUMG16zYT7PoUgk8gP/BC9Yg==',
      contributorsPath: '/projects/1/contributors',
      awardsPath      : '/projects/1/awards',
      editPath        : '/projects/1/edit'
    }
    const wrapper = mount(<Project {...props} />)

    expect(wrapper.find('.project-header__menu__back').text()).toBe('First Mission')
    expect(wrapper.find('.project-header__name').text()).toBe(' Core Network ')
    expect(wrapper.find('.project-header__owner').text()).toBe(' by Test User ')
    expect(wrapper.find('.project-award__token__left').text()).toBe('Ether (HOT)')
    expect(wrapper.find('.project-leader__info').text()).toBe('Team LeaderUser Leader ')
    expect(wrapper.find('.project-description__text').text()).toBe('The last social network.Test')
  })
})
