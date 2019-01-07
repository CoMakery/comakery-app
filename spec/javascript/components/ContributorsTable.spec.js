import React from 'react'
import { shallow } from 'enzyme'
import ContributorsTable from 'components/ContributorsTable'

describe('Contributors Table', () => {
  it('renders component correctly without props', () => {
    const wrapper = shallow(<ContributorsTable />)

    expect(wrapper).toMatchSnapshot()
  })

  it('renders component correctly without revenue share', () => {
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

  it('renders component correctly with revenue share', () => {
    const tableData = [
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
        'total'    : '49,877',
        'remaining': '49,377',
        'unpaid'   : '$1,348.68',
        'paid'     : '$15.08'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper).toMatchSnapshot()
  })

  it('shows table with USD', () => {
    const tableData = [
      {
        'imageUrl' : '/test2.png',
        'name'     : 'Betsy',
        'awards'   : [],
        'total'    : '49,877',
        'remaining': '49,377',
        'unpaid'   : '$1,348.68',
        'paid'     : '$15.08'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper.text()).toContain('Contributors')
    expect(wrapper.exists('td.contributor')).toBe(true)
    expect(wrapper.find('td.contributor').first().text()).toContain('Betsy')
    expect(wrapper.find('td.awards-earned').first().text()).toContain('49,877')
    expect(wrapper.find('td.paid').first().text()).toContain('$15.08')
    expect(wrapper.find('td.award-holdings').first().text()).toContain('49,377')
    expect(wrapper.find('td.holdings-value').first().text()).toContain('$1,348.68')
  })

  it('shows table with Bittoken', () => {
    const tableData = [
      {
        'imageUrl' : '/test2.png',
        'name'     : 'Betsy',
        'awards'   : [],
        'total'    : '0',
        'remaining': '0',
        'unpaid'   : '฿0',
        'paid'     : '฿0'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper.find('td.paid').first().text()).toContain('฿0')
    expect(wrapper.find('td.holdings-value').first().text()).toContain('฿0')
  })

  it('shows table with Eth', () => {
    const tableData = [
      {
        'imageUrl' : '/test2.png',
        'name'     : 'Betsy',
        'awards'   : [],
        'total'    : '0',
        'remaining': '0',
        'unpaid'   : 'Ξ0',
        'paid'     : 'Ξ0'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper.find('td.paid').first().text()).toContain('Ξ0')
    expect(wrapper.find('td.holdings-value').first().text()).toContain('Ξ0')
  })

  it('shows table without revenue share', () => {
    const tableData = [
      {
        'imageUrl' : '/test2.png',
        'name'     : 'Betsy',
        'awards'   : [],
        'total'    : '49,877',
        'remaining': '49,377',
        'unpaid'   : '$1,348.68',
        'paid'     : '$15.08'
      }
    ]
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.text()).toContain('Contributors')
    expect(wrapper.exists('td.contributor')).toBe(true)
    expect(wrapper.find('td.contributor').first().text()).toContain('Betsy')
    expect(wrapper.find('td.awards-earned').first().text()).toContain('49,877')
    expect(wrapper.exists('td.paid')).toBe(false)
    expect(wrapper.exists('td.award-holdings')).toBe(false)
    expect(wrapper.exists('td.holdings-value')).toBe(false)
    expect(wrapper.text()).not.toContain('$')
    expect(wrapper.text()).not.toContain('Paid')
  })

  it('hides table without contributors', () => {
    const tableData = []
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.exists('td.contributor')).toBe(false)
    expect(wrapper.exists('td.awards-earned')).toBe(false)
    expect(wrapper.exists('td.paid')).toBe(false)
    expect(wrapper.exists('td.award-holdings')).toBe(false)
    expect(wrapper.exists('td.holdings-value')).toBe(false)
  })
})
