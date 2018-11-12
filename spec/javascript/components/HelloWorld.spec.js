import React from 'react'
import HelloWorld from 'components/HelloWorld'
import { shallow } from 'enzyme'

describe('HelloWorld', function() {
  const greeting = 'Hey there'
  let component

  beforeEach(() => {
    component = shallow(<HelloWorld greeting = {greeting}/>)
  })

  it('has text containing props.greeting', () => {
    expect(component.text()).toContain(greeting)
  })

  it('hasn\'t changed', () => {
    expect(component).toMatchSnapshot()
  })
})
