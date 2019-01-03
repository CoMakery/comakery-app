import React from 'react'
import { shallow } from 'enzyme'
import ContributorsTable from 'components/ContributorsTable'

describe('Contributors Table', () => {
  it('renders component correctly without props', () => {
<<<<<<< HEAD
    const component = renderer.create(<ContributorsTable />)
    expect(component.toJSON()).toMatchSnapshot()
=======
    const wrapper = shallow(<ContributorsTable />)

    expect(wrapper).toMatchSnapshot()
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
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
<<<<<<< HEAD
    const component = renderer.create(<ContributorsTable tableData={tableData} />)
    expect(component.toJSON()).toMatchSnapshot()
=======
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper).toMatchSnapshot()
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
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
<<<<<<< HEAD
    const component = renderer.create(<ContributorsTable tableData={tableData} revenueShare />)
    expect(component.toJSON()).toMatchSnapshot()
=======
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper).toMatchSnapshot()
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
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
<<<<<<< HEAD
    const component = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(component.text()).toContain('Contributors')
    expect(component.exists('td.contributor')).toBeTruthy
    expect(component.find('td.contributor').first().text()).toContain('Betsy')
    expect(component.find('td.awards-earned').first().text()).toContain('49,877')
    expect(component.find('td.paid').first().text()).toContain('$15.08')
    expect(component.find('td.award-holdings').first().text()).toContain('49,377')
    expect(component.find('td.holdings-value').first().text()).toContain('$1,348.68')
=======
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper.text()).toContain('Contributors')
    expect(wrapper.exists('td.contributor')).toBe(true)
    expect(wrapper.find('td.contributor').first().text()).toContain('Betsy')
    expect(wrapper.find('td.awards-earned').first().text()).toContain('49,877')
    expect(wrapper.find('td.paid').first().text()).toContain('$15.08')
    expect(wrapper.find('td.award-holdings').first().text()).toContain('49,377')
    expect(wrapper.find('td.holdings-value').first().text()).toContain('$1,348.68')
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
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
<<<<<<< HEAD
    const component = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(component.find('td.paid').first().text()).toContain('฿0')
    expect(component.find('td.holdings-value').first().text()).toContain('฿0')
=======
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper.find('td.paid').first().text()).toContain('฿0')
    expect(wrapper.find('td.holdings-value').first().text()).toContain('฿0')
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
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
<<<<<<< HEAD
    const component = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(component.find('td.paid').first().text()).toContain('Ξ0')
    expect(component.find('td.holdings-value').first().text()).toContain('Ξ0')
=======
    const wrapper = shallow(<ContributorsTable tableData={tableData} revenueShare />)
    expect(wrapper.find('td.paid').first().text()).toContain('Ξ0')
    expect(wrapper.find('td.holdings-value').first().text()).toContain('Ξ0')
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
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
<<<<<<< HEAD
    const component = shallow(<ContributorsTable tableData={tableData} />)
    expect(component.text()).toContain('Contributors')
    expect(component.exists('td.contributor')).toBeTruthy
    expect(component.find('td.contributor').first().text()).toContain('Betsy')
    expect(component.find('td.awards-earned').first().text()).toContain('49,877')
    expect(component.exists('td.paid')).not.toBeTruthy
    expect(component.exists('td.award-holdings')).not.toBeTruthy
    expect(component.exists('td.holdings-value')).not.toBeTruthy
    expect(component.text()).not.toContain('$')
    expect(component.text()).not.toContain('Paid')
=======
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
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
  })

  it('hides table without contributors', () => {
    const tableData = []
<<<<<<< HEAD
    const component = shallow(<ContributorsTable tableData={tableData} />)
    expect(component.exists('td.contributor')).not.toBeTruthy
    expect(component.exists('td.awards-earned')).not.toBeTruthy
    expect(component.exists('td.paid')).not.toBeTruthy
    expect(component.exists('td.award-holdings')).not.toBeTruthy
    expect(component.exists('td.holdings-value')).not.toBeTruthy
=======
    const wrapper = shallow(<ContributorsTable tableData={tableData} />)
    expect(wrapper.exists('td.contributor')).toBe(false)
    expect(wrapper.exists('td.awards-earned')).toBe(false)
    expect(wrapper.exists('td.paid')).toBe(false)
    expect(wrapper.exists('td.award-holdings')).toBe(false)
    expect(wrapper.exists('td.holdings-value')).toBe(false)
>>>>>>> 90996aa9e0f06f1e6b5468fd279ee52e2e4d208e
  })
})
