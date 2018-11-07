import React from 'react'
import renderer from 'react-test-renderer'
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
          ]
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
          ]
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
})