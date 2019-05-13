import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

const Element = styled.div`
  display: flex;
  flex-direction: column;
  padding-right: 40px;
`

const Title = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
  text-transform: uppercase;
  margin-bottom: 3px;
`

const Children = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #4a4a4a;
`

class ContentElement extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Element>
          <Title>
            {this.props.title}
          </Title>
          <Children>
            {this.props.children}
          </Children>
        </Element>
      </React.Fragment>
    )
  }
}

ContentElement.propTypes = {
  title: PropTypes.string.isRequired
}
ContentElement.defaultProps = {
  title: ''
}
export default ContentElement
