import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

const Block = styled.div`
  margin-bottom: 25px;
`

const Title = styled.div`
  font-family: Montserrat;
  font-size: 12px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
  text-transform: uppercase;
  margin-bottom: 5px;
`

const Children = styled.div`
  font-family: Georgia;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #4a4a4a;

  a {
    color: #0089f4;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
`

class ContentBlock extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Block>
          <Title>
            {this.props.title}
          </Title>
          <Children>
            {this.props.children}
          </Children>
        </Block>
      </React.Fragment>
    )
  }
}

ContentBlock.propTypes = {
  title: PropTypes.string.isRequired
}
ContentBlock.defaultProps = {
  title: ''
}
export default ContentBlock
