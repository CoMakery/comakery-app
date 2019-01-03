import React from 'react'
import renderer from 'react-test-renderer'
import { shallow } from 'enzyme'
import ContributorsTable from 'components/ContributorsTable'

describe('Contributors Table', () => {
    it('renders component correctly without props', () => {
      const component = renderer.create(<ContributorsTable/>)
      expect(component.toJSON()).toMatchSnapshot()
    })
    
    it('renders component correctly without revenue share', () => {
      const tableData = [
        {
          "imageUrl": "/test.png",
          "name": "Joe",
          "awards": [
           {
             "name": "Idea leading to patent",
             "total": "7,000"
           }
          ],
          "total": "0"
        },
        {
          "imageUrl": "/test2.png",
          "name": "Betsy",
          "awards": [
           {
             "name": "Bugfix",
             "total": "20,000"
           },
           {
             "name": "Contribution",
             "total": "5,333"
           }
          ],
          "total": "0"
        }
      ]
      const component = renderer.create(<ContributorsTable tableData={tableData} />)
      expect(component.toJSON()).toMatchSnapshot()
    })
    
    it('renders component correctly with revenue share', () => {
      const tableData = [
        {
          "imageUrl": "/test2.png",
          "name": "Betsy",
          "awards": [
           {
             "name": "Bugfix",
             "total": "20,000"
           },
           {
             "name": "Contribution",
             "total": "5,333"
           }
          ],
          "total": "49,877",
          "remaining": "49,377",
          "unpaid": "$1,348.68",
          "paid": "$15.08"
        }
      ]
      const component = renderer.create(<ContributorsTable tableData={tableData} revenueShare={true} />)
      expect(component.toJSON()).toMatchSnapshot()
    })
    
    it('shows table with USD', () => {
      const tableData = [
        {
          "imageUrl": "/test2.png",
          "name": "Betsy",
          "awards": [],
          "total": "49,877",
          "remaining": "49,377",
          "unpaid": "$1,348.68",
          "paid": "$15.08"
        }
      ]
      const component = shallow(<ContributorsTable  tableData={tableData} revenueShare={true}/>)
      expect(component.text()).toContain('Contributors')
      expect(component.exists('td.contributor')).toBeTruthy
      expect(component.find('td.contributor').first().text()).toContain('Betsy')
      expect(component.find('td.awards-earned').first().text()).toContain('49,877')
      expect(component.find('td.paid').first().text()).toContain('$15.08')
      expect(component.find('td.award-holdings').first().text()).toContain('49,377')
      expect(component.find('td.holdings-value').first().text()).toContain('$1,348.68')
    })
    
    it('shows table with Bittoken', () => {
      const tableData = [
        {
          "imageUrl": "/test2.png",
          "name": "Betsy",
          "awards": [],
          "total": "0",
          "remaining": "0",
          "unpaid": "฿0",
          "paid": "฿0"
        }
      ]
      const component = shallow(<ContributorsTable  tableData={tableData} revenueShare={true}/>)
      expect(component.find('td.paid').first().text()).toContain('฿0')
      expect(component.find('td.holdings-value').first().text()).toContain('฿0')
    })
    
    it('shows table with Eth', () => {
      const tableData = [
        {
          "imageUrl": "/test2.png",
          "name": "Betsy",
          "awards": [],
          "total": "0",
          "remaining": "0",
          "unpaid": "Ξ0",
          "paid": "Ξ0"
        }
      ]
      const component = shallow(<ContributorsTable  tableData={tableData} revenueShare={true}/>)
      expect(component.find('td.paid').first().text()).toContain('Ξ0')
      expect(component.find('td.holdings-value').first().text()).toContain('Ξ0')
    })
    
    it('shows table without revenue share', () => {
      const tableData = [
        {
          "imageUrl": "/test2.png",
          "name": "Betsy",
          "awards": [],
          "total": "49,877",
          "remaining": "49,377",
          "unpaid": "$1,348.68",
          "paid": "$15.08"
        }
      ]
      const component = shallow(<ContributorsTable  tableData={tableData}/>)
      expect(component.text()).toContain('Contributors')
      expect(component.exists('td.contributor')).toBeTruthy
      expect(component.find('td.contributor').first().text()).toContain('Betsy')
      expect(component.find('td.awards-earned').first().text()).toContain('49,877')
      expect(component.exists('td.paid')).not.toBeTruthy
      expect(component.exists('td.award-holdings')).not.toBeTruthy
      expect(component.exists('td.holdings-value')).not.toBeTruthy
      expect(component.text()).not.toContain('$')
      expect(component.text()).not.toContain('Paid')
    })
    
    it('hides table without contributors', () => {
      const tableData = []
      const component = shallow(<ContributorsTable  tableData={tableData}/>)
      expect(component.exists('td.contributor')).not.toBeTruthy
      expect(component.exists('td.awards-earned')).not.toBeTruthy
      expect(component.exists('td.paid')).not.toBeTruthy
      expect(component.exists('td.award-holdings')).not.toBeTruthy
      expect(component.exists('td.holdings-value')).not.toBeTruthy
    })
})