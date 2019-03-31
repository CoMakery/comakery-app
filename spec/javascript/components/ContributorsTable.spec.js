import React from 'react'
import { shallow } from 'enzyme'
import ContributorsTable from 'components/ContributorsTable'

describe('Contributors Table', () => {
  it('renders component correctly without props', () => {
    const wrapper = shallow(<ContributorsTable />)

    expect(wrapper).toMatchSnapshot()
  })

  it('renders component correctly with tableData', () => {
    const tableData = [
      {
        'imageUrl': '/test.png',
        'name'    : 'Joe',
        'awards'  : [
          {
            'name' : 'Idea leading to patent',
            'total': '7,000'
          }
        ],
        'total': '0'
      },
      {
        'imageUrl': '/test2.png',
        'name'    : 'Betsy',
        'awards'  : [
          {
            'name' : 'Bugfix',
            'total': '20,000'
          },
          {
            'name' : 'Contribution',
            'total': '5,333'
          }
        ],
        'total': '0'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper).toMatchSnapshot()
  })

  it('shows table with USD', () => {
    const tableData = [
      {
        'imageUrl': '/test2.png',
        'name'    : 'Betsy',
        'awards'  : [],
        'total'   : '49,877'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.text()).toContain('Contributors')
    expect(wrapper.exists('td.contributor')).toBe(true)
    expect(wrapper.find('td.contributor').first().text()).toContain('Betsy')
    expect(wrapper.find('td.awards-earned').first().text()).toContain('49,877')
  })

  it('shows table with BTC', () => {
    const tableData = [
      {
        'imageUrl': '/test2.png',
        'name'    : 'Betsy',
        'awards'  : [],
        'total'   : '฿0'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.find('td.awards-earned').first().text()).toContain('฿0')
  })

  it('shows table with ETH', () => {
    const tableData = [
      {
        'imageUrl': '/test2.png',
        'name'    : 'Betsy',
        'awards'  : [],
        'total'   : 'Ξ0'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.find('td.awards-earned').first().text()).toContain('Ξ0')
  })

  it('shows table', () => {
    const tableData = [
      {
        'imageUrl': '/test2.png',
        'name'    : 'Betsy',
        'awards'  : [],
        'total'   : '49,877'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.text()).toContain('Contributors')
    expect(wrapper.exists('td.contributor')).toBe(true)
    expect(wrapper.find('td.contributor').first().text()).toContain('Betsy')
    expect(wrapper.find('td.awards-earned').first().text()).toContain('49,877')
    expect(wrapper.text()).not.toContain('$')
    expect(wrapper.text()).not.toContain('Paid')
  })

  it('hides table without contributors', () => {
    const tableData = []
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.exists('td.contributor')).toBe(false)
    expect(wrapper.exists('td.awards-earned')).toBe(false)
  })
})
