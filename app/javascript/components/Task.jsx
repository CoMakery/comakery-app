import React from 'react'
import PropTypes from 'prop-types'
import styled, { css } from 'styled-components'
import Icon from './styleguide/Icon'
import CurrencyAmount from './CurrencyAmount'

const Wrapper = styled.div`
  display: flex;
  flex-direction: row;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  height: 60px;
  margin-bottom: 10px;
`

const RightBorder = styled.div`
  width: 2px;
  height: 60px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, .2);
  background-color: #5037f7;
  z-index: 10;
  position: absolute;
  margin-left: -1px;

  ${props => props.status === 'ready' && css`
    background-color: #5037f7;
  `}

  ${props => props.status === 'accepted' && css`
    background-color: #7ed321;
  `}

  ${props => props.status === 'paid' && css`
    background-color: #fb40e5;
  `}
`

const Info = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
`

const Name = styled.div`
  font-family: Montserrat;
  font-size: 14px;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
  padding-bottom: 8px;
`

const Status = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-transform: uppercase;

  ${props => props.status === 'ready' && css`
    color: #5037f7;
  `}

  ${props => props.status === 'accepted' && css`
    color: #7ed321;
  `}

  ${props => props.status === 'paid' && css`
    color: #fb40e5;
  `}
`

const Title = styled.div`
  padding: 7px 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`

const Details = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: space-between;
`

const Amount = styled(CurrencyAmount)`
`

const Buttons = styled.div`
  display: flex;
  justify-content: space-between;
  margin-right: 15px;
  align-items: center;
  padding-top: 8px;
`

const PaymentButton = styled.a`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #0089f4;
  text-decoration: none;
  text-transform: uppercase;

  &:hover,
  &:focus {
    text-decoration: underline;
  }
`

const StyledIcon = styled(Icon)`
  height: 15px;
  margin-left: 16px;
`

class Task extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Wrapper>
          <RightBorder status={this.props.task.status} />
          <Info>
            <Title>
              <Name>
                {this.props.task.name || 'Unnamed Task'}
              </Name>

              <Status status={this.props.task.status}>
                {this.props.task.status}
              </Status>
            </Title>

            <Details>
              <Amount
                amount={this.props.task.totalAmount}
                currency={this.props.task.currency}
                logoUrl={this.props.task.currencyLogo}
              />

              <Buttons>
                {this.props.task.status === 'ready' &&
                <PaymentButton href={this.props.task.awardPath}>
                    issue award
                </PaymentButton>
                }
                {this.props.task.status === 'accepted' &&
                <PaymentButton href={this.props.task.payPath}>
                    pay contributor
                </PaymentButton>
                }
                <a href={this.props.task.editPath}>
                  <StyledIcon name="iconEdit.svg" />
                </a>
                <a rel="nofollow" data-method="delete" href={this.props.task.destroyPath}>
                  <StyledIcon name="iconTrash.svg" />
                </a>
              </Buttons>
            </Details>
          </Info>
        </Wrapper>
      </React.Fragment>
    )
  }
}

Task.propTypes = {
  task: PropTypes.object
}
Task.defaultProps = {
  task: {
    status: null
  }
}
export default Task
