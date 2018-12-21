import React from 'react'
import D3Pie from 'd3pie'
import renderer from 'react-test-renderer'
import { shallow } from 'enzyme'
import ContributorsSummaryPieChart from 'components/ContributorsSummaryPieChart'

describe('Contributors Summary Pie Chart', () => {
  it('renders component correctly', () => {
    const component = renderer.create(<ContributorsSummaryPieChart />)
    expect(component.toJSON()).toMatchSnapshot()
    // D3Pie relies on D3 which requires an actual DOM to operate,
    // so we are not able to access the chart in this test environment.
    // D3 can be fooled by faux DOM such as https://github.com/Olical/react-faux-dom,
    // but it looks kinda hacky and in our case might be an overkill.
  })
  it('has correct header', () => {
    const component = shallow(<ContributorsSummaryPieChart />)
    expect(component.find('h3').text()).toEqual('Total Tokens Awarded To Contributors')
  })
})
