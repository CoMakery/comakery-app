import React from 'react'
import { shallow } from 'enzyme'
import ContributorsSummaryPieChart from 'components/ContributorsSummaryPieChart'

describe('Contributors Summary Pie Chart', () => {
  it('renders component correctly', () => {
    const wrapper = shallow(<ContributorsSummaryPieChart />)

    expect(wrapper).toMatchSnapshot()
    expect(wrapper.find('h3').text()).toBe('Total Tokens Awarded To Contributors')
  })
})
