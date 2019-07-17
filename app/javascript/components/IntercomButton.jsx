import React from 'react'
import styled from 'styled-components'
import chatImg from '../src/images/featured/chat.svg'

const Button = styled.div`
  position: fixed;
  bottom: 30px;
  right: 30px;
  z-index: 100;
  width: 72px;
  height: 72px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #0089f4;
  border-radius: 50%;
  cursor: pointer;
`

class IntercomButton extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Button className="intercom intercom-button">
          <img src={chatImg} />
        </Button>
      </React.Fragment>
    )
  }
}

export default IntercomButton
