import React from 'react'
import { mount } from 'enzyme'
import Mission from 'components/Mission'

describe('Mission', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<Mission />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.exists('.mission-container')).toBe(true)
    expect(wrapper.exists('.mission-header')).toBe(true)
    expect(wrapper.exists('.mission-details')).toBe(true)
    expect(wrapper.exists('.mission-leaders')).toBe(true)
    expect(wrapper.exists('.mission-stats')).toBe(true)
    expect(wrapper.exists('.mission-projects')).toBe(true)
  })

  it('renders correctly with props', () => {
    const props = {
      csrfToken: 'CtB6XLxhOE4xZ+SZ3IxMAPYTZ18b4FLjEQqrecPJVoKibXnW98WIASgvKbbqbcoHPF0EdhePqyQ8VfTL/dubKQ==',
      leaders  : [
        {
          count      : 4,
          firstName  : 'User1',
          id         : 1,
          imageUrl   : '/attachments/image',
          lastName   : 'Last1',
          projectName: 'test live call'
        },
        {
          count      : 2,
          firstName  : 'User2',
          id         : 2,
          imageUrl   : '/attachments/image',
          lastName   : 'Last2',
          projectName: 'test live call'
        },
        {
          count      : 3,
          firstName  : 'User3',
          id         : 3,
          imageUrl   : '/attachments/image',
          lastName   : 'Last3',
          projectName: 'test live call'
        }
      ],
      mission: {
        description: 'Holochain Description',
        id         : 1,
        imageUrl   : '/attachments/image.jpg',
        logoUrl    : '/attachments/logo.jpg',
        name       : 'HOLOCHAIN',
        subtitle   : 'Test Mission',
        stats      : {batches: 19, interests: 1, projects: 6, tasks: 369}
      },
      tokens: {
        tokenCount: 6,
        tokens    : [
          {
            contractUrl: 'https://testnet.qtum.org/token/test',
            count      : 2,
            id         : 1,
            logoUrl    : '/attachments/test logo',
            name       : 'QRC Token 1',
            projectName: 'test live call',
            symbol     : 'BIG'
          },
          {
            contractUrl: 'https://testnet.qtum.org/token/test',
            count      : 2,
            id         : 2,
            logoUrl    : '/attachments/test logo',
            name       : 'QRC Token 2',
            projectName: 'test live call',
            symbol     : 'BIG'
          },
          {
            contractUrl: 'https://testnet.qtum.org/token/test',
            count      : 2,
            id         : 3,
            logoUrl    : '/attachments/test logo',
            name       : 'QRC Token 3',
            projectName: 'test live call',
            symbol     : 'BIG'
          },
          {
            contractUrl: 'https://testnet.qtum.org/token/test',
            count      : 2,
            id         : 4,
            logoUrl    : '/attachments/test logo',
            name       : 'QRC Token 4',
            projectName: 'test live call',
            symbol     : 'BIG'
          }
        ]
      },
      projects: [
        {
          editable  : true,
          interested: false,
          stats     : {
            batches  : 3,
            tasks    : 0,
            interests: 0
          },
          projectData: {
            team           : [],
            teamSize       : 0,
            defaultImageUrl: 'defaultImg',
            description    : 'yes',
            id             : 60,
            imageUrl       : 'testimage',
            owner          : 'Test User',
            squareUrl      : 'test image',
            title          : 'test live call',
            teamLeader     : {
              firstName: 'Test user',
              id       : 1,
              imageUrl : '/attachments/test.jpg',
              lastName : 'Test',
              nickname : ''
            },
          },
          tokenData: {
            logoUrl: '/attachments/token image',
            name   : 'QRC Token'
          }
        },
        {
          editable  : true,
          interested: false,
          stats     : {
            batches  : 3,
            tasks    : 0,
            interests: 0
          },
          projectData: {
            team           : [],
            teamSize       : 0,
            defaultImageUrl: 'defaultImg',
            description    : 'yes',
            id             : 61,
            imageUrl       : 'testimage',
            owner          : 'Test User',
            squareUrl      : 'test image',
            title          : 'test live call',
            teamLeader     : {
              firstName: 'Test user',
              id       : 1,
              imageUrl : '/attachments/test.jpg',
              lastName : 'Test',
              nickname : ''
            },
          },
          tokenData: {
            logoUrl: '/attachments/token image2',
            name   : 'QRC Token2'
          }
        },
      ],
      newProjectUrl: '/projects/new?mission_id=test',

    }
    const wrapper = mount(<Mission {...props} />)

    expect(wrapper.find('.mission-details__name').text()).toBe('HOLOCHAIN')
    expect(wrapper.find('.mission-details__subtitle').text()).toBe('Test Mission')
    expect(wrapper.find('.mission-details__description').text()).toBe('Holochain Description')

    expect(wrapper.find('.mission-leaders__individual')).toHaveLength(3)
    expect(wrapper.contains(<div className="mission-leaders__individual__info__name">User1 Last1</div>)).toEqual(true)
    expect(wrapper.contains(<div className="mission-leaders__individual__info__name">User2 Last2</div>)).toEqual(true)
    expect(wrapper.contains(<div className="mission-leaders__individual__info__name">User3 Last3</div>)).toEqual(true)

    expect(wrapper.find('.mission-stats__kpi')).toHaveLength(3)
    expect(wrapper.find('.mission-projects__single')).toHaveLength(2)
  })
})
