import React from 'react'
import PropTypes from 'prop-types'
import styled, { css } from 'styled-components'
import Icon from './styleguide/Icon'
import Userpics from './Userpics'
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
    background-color: #4a4a4a;
  `}

  ${props => props.status === 'started' && css`
    background-color: #008e9b;
  `}

  ${props => props.status === 'submitted' && css`
    background-color: #007ae7;
  `}

  ${props => props.status === 'accepted' && css`
    background-color: #5037f7;
  `}

  ${props => props.status === 'paid' && css`
    background-color: #fb40e5;
  `}

  ${props => props.status === 'rejected' && css`
    background-color: #ff4d4d;
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

const StatusWrapper = styled.div`
  display: flex;
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
  margin-right: 2em;

  ${props => props.status === 'ready' && css`
    color: #4a4a4a;
  `}

  ${props => props.status === 'started' && css`
    color: #008e9b;
  `}

  ${props => props.status === 'submitted' && css`
    color: #007ae7;
  `}

  ${props => props.status === 'accepted' && css`
    color: #5037f7;
  `}

  ${props => props.status === 'paid' && css`
    color: #fb40e5;
  `}

  ${props => props.status === 'rejected' && css`
    color: #ff4d4d;
  `}
`

const Contributor = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: 500;
  color: #4a4a4a;
  text-transform: uppercase;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  flex-wrap: nowrap;
  display: flex;
  margin-right: 2em;

  b {
    font-weight: 900;
  }
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
  width: 15px;
  margin-left: 16px;
`

const IconPlaceholder = styled.span`
  display: inline-block; 
  height: 15px;
  width: 15px;
  margin-left: 16px;
`

class Task extends React.Component {
  render() {
    let task = this.props.task
    return (
      <React.Fragment>
        <Wrapper>
          <RightBorder status={task.status} />
          <Info>
            <Title>
              <Name>
                {task.name || task.batchName}
              </Name>

              <StatusWrapper>
                <Status status={task.status}>
                  {task.status}
                </Status>

                {task.contributor.name &&
                  <Contributor>
                    <Userpics pics={[task.contributor.image]} limit={1} />
                    {task.contributor.name}
                  </Contributor>
                }
              </StatusWrapper>
            </Title>

            <Details>
              <Amount
                amount={task.totalAmount}
                currency={task.currency}
                logoUrl={task.currencyLogo}
              />

              <Buttons>
                {task.status === 'ready' &&
                <PaymentButton href={task.awardPath}>
                    issue award
                </PaymentButton>
                }
                {task.status === 'accepted' &&
                <PaymentButton href={task.payPath}>
                    pay contributor
                </PaymentButton>
                }
                <a href={task.clonePath}>
                  <StyledIcon name="DUPLICATE.svg" />
                </a>
                <a href={task.editPath}>
                  <StyledIcon name="iconEdit.svg" />
                </a>
                {task.destroyPath &&
                  <a rel="nofollow" data-method="delete" href={task.destroyPath}>
                    <StyledIcon name="iconTrash.svg" />
                  </a>
                }
                {!task.destroyPath &&
                  <IconPlaceholder />
                }
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
    status: null,
    contributor: {
      name : null,
      image: null
    }
  }
}
export default Task
