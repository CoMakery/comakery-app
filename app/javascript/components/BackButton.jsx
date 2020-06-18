import React from 'react'
import Icon from './styleguide/Icon'
import styled from 'styled-components'

const Wrapper = styled.div`
  position: absolute;
  top: 20px;
  left: 20px;
  cursor: pointer;

  @media (max-width: 1024px) {
    display: none;
  }
`

class BackButton extends React.Component {
  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
  }

  render() {
    return (
      <React.Fragment>
        <Wrapper>
          <Icon name='iconCloseCopy.svg' onClick={this.goBack} />
        </Wrapper>
      </React.Fragment>
    )
  }
}

export default BackButton
