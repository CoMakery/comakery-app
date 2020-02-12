import React from 'react'
import PropTypes from 'prop-types'
import CurrencyAmount from './CurrencyAmount'
import Userpics from './Userpics'
import Icon from './styleguide/Icon'
import styled, { css } from 'styled-components'

const Wrapper = styled.div`
  display: flex;
  flex-direction: row-reverse;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  height: auto;
  padding: 10px 20px;
  margin-bottom: 20px;
  text-transform: uppercase;
  background-color: white;
  align-items: flex-start;
  justify-content: space-between;
  border-radius: 3px;
`

const ExpandButton = styled.div`
  box-shadow: 0 5px 10px 0 rgba(0,0,0,0.1);
  background: white;
  margin-right: -20px;
  margin-top: -10px;
  margin-left: 1em;
  padding: 5px 5px 0px 5px;
  z-index: 1;
  cursor: pointer;

  img {
    width: 15px;
    height: 15px;
  }
`

const Rows = styled.div`
  align-self: flex-start;
  width: 100%;
`

const FirstRow = styled.div`
  margin-bottom: 10px;
  display: flex;
  width: 100%;
  justify-content: space-between;
  align-items: flex-start;

  @media (max-width: 1024px) {
    flex-direction: column;
  }
`

const SecondRow = styled.div`
  min-height: 28px;
  margin-bottom: 10px;
  display: flex;
  width: 100%;
  justify-content: space-between;
  align-items: center;

  @media (max-width: 1024px) {
    flex-direction: column;
  }
`

const ThirdRow = styled.div`
  display: flex;
  width: 100%;

  @media (max-width: 1024px) {
    flex-direction: column;
  }
`

const Name = styled.div`
  font-family: Montserrat;
  font-size: 16px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;

  @media (max-width: 1024px) {
    margin-bottom: 15px;
  }
`

const BlockWrapper = styled.div`
  margin-right: auto;
`

const Mission = styled.div`
  font-family: Montserrat;
  font-size: 12px;
  font-weight: 900;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.4;
  letter-spacing: normal;
  color: #4a4a4a;

  a {
    text-decoration: none;
    color: #0089f4;
    font-weight: 600;

    &:hover {
      text-decoration: underline;
    }

    @media (max-width: 1024px) {
      display: block;
    }
  }

  @media (max-width: 1024px) {
    margin-bottom: 15px;
  }
`

const Project = styled.div`
  font-family: Montserrat;
  font-size: 12px;
  font-weight: 900;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.4;
  letter-spacing: normal;
  color: #4a4a4a;

  a {
    text-decoration: none;
    color: #0089f4;
    font-weight: 600;

    &:hover {
      text-decoration: underline;
    }

    @media (max-width: 1024px) {
      display: block;
    }
  }

  img {
    height: 12px;
    margin-bottom: -1px;
    margin-left: 0.5em;
    opacity: 0.2;

    &:hover {
      opacity: 1;
    }
  }

  @media (max-width: 1024px) {
    margin-bottom: 15px;
    margin-top: 15px;
  }
`

const TaskAction = styled.a`
  ${props => props.componentStyle === 'link' && css`
    font-family: Montserrat;
    font-size: 14px;
    font-weight: bold;
    font-style: normal;
    font-stretch: normal;
    line-height: normal;
    letter-spacing: normal;
    text-align: right;
    color: #3a3a3a;
    text-transform: uppercase;
    text-decoration: none;
    margin-left: auto;

    &:hover {
      text-decoration: underline;
    }

    @media (max-width: 1024px) {
      display: none;
    }
  `}

  ${props => props.componentStyle === 'button' && css`
    display: none;
    text-decoration: none;
    height: 30px;
    padding: 6px 12px;
    margin-right: 15px;
    min-width: 90px;
    color: white;
    background-color: #8d9599;
    box-shadow: 0 5px 10px 0 rgba(32, 22, 98, .1);
    font-family: Montserrat, sans-serif;
    font-size: 14px;
    font-weight: bold;
    text-transform: uppercase;
    outline: none;
    border: none;
    border-radius: 0;
    transition: none;
    cursor: pointer;
    box-sizing: border-box;
    appearance: none;
    align-items: flex-start;
    text-align: center;
    margin-bottom: 15px;
    width: fit-content;

    &:hover {
      text-decoration: underline;
    }

    @media (max-width: 1024px) {
      display: inline-block;
    }
  `}

  ${props => props.actionAvailable && props.componentStyle === 'link' && css`
    color: #0089f4;
  `}

  ${props => props.actionAvailable && props.componentStyle === 'button' && css`
    background-color: #0089f4;
  `}
`

const TaskDetails = styled.a`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #201662;
  margin-left: auto;
  text-transform: uppercase;
  text-decoration: none;
  display: flex;
  flex-direction: row;
  align-items: center;

  &:hover {
    text-decoration: underline;
  }

  img {
    margin-left: 7px;
    ${props => props.displayActions && css`
      transform: rotate(270deg);
    `}
  }

  @media (max-width: 1024px) {
    margin-left: initial;
    margin-top: 15px;
    margin-bottom: 15px;
  }
`

const Status = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  color: #4a4a4a;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  margin-right: 2em;

  b {
    font-weight: 900;
  }
`

const Type = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: 500;
  color: #4a4a4a;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  margin-right: 2em;

  b {
    font-weight: 900;
  }
`

const ExperienceLevel = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: 500;
  color: #4a4a4a;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  margin-right: 2em;

  b {
    font-weight: 900;
  }
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
    margin-right: 0.5em;
  }

  @media (max-width: 1024px) {
    margin-top: 15px;
  }
`

class TaskActionComponent extends React.Component {
  render() {
    let task = this.props.task
    let filter = this.props.filter

    if (task.allowedToStart) {
      return (
        <TaskAction
          componentStyle={this.props.componentStyle}
          href={
            ((task.status === 'accepted' && task.policies.pay) && task.paymentUrl) ||
            ((task.status === 'paid') && task.paymentUrl) ||
            ((task.status === 'accepted' && !task.policies.pay && !task.contributor.walletPresent) && '/account') ||
            (task.detailsUrl)
          }
          actionAvailable={
            (task.status === 'ready') ||
            (task.status === 'started') ||
            (task.status === 'submitted' && task.policies.review) ||
            (task.status === 'accepted' && !task.policies.pay && !task.contributor.walletPresent) ||
            (task.status === 'accepted' && task.policies.pay && task.contributor.walletPresent)
          }
        >
          {task.status === 'ready' &&
            <React.Fragment>Start Task</React.Fragment>
          }
          {task.status === 'started' &&
            <React.Fragment>Submit Task</React.Fragment>
          }
          {task.status === 'submitted' && filter !== 'to review' &&
            <React.Fragment>Awaiting Review</React.Fragment>
          }
          {task.status === 'submitted' && filter === 'to review' &&
            <React.Fragment>Review Task</React.Fragment>
          }
          {task.status === 'accepted' && filter !== 'to pay' && task.contributor.walletPresent &&
            <React.Fragment>Awaiting Payment</React.Fragment>
          }
          {task.status === 'accepted' && filter !== 'to pay' && !task.contributor.walletPresent &&
            <React.Fragment>Provide Wallet</React.Fragment>
          }
          {task.status === 'accepted' && filter === 'to pay' && task.contributor.walletPresent &&
            <React.Fragment>Pay Contributor</React.Fragment>
          }
          {task.status === 'accepted' && filter === 'to pay' && !task.contributor.walletPresent &&
            <React.Fragment>Account Pending</React.Fragment>
          }
          {task.status === 'paid' &&
            <React.Fragment>Paid</React.Fragment>
          }
          {task.status === 'rejected' &&
            <React.Fragment>Rejected</React.Fragment>
          }
        </TaskAction>
      )
    } else if (task.reachedMaximumAssignments) {
      return (
        <TaskAction
          componentStyle={this.props.componentStyle}
          href={task.detailsUrl}
          actionAvailable
        >
          <React.Fragment>Task Completed</React.Fragment>
        </TaskAction>
      )
    } else {
      return (
        <TaskAction
          componentStyle={this.props.componentStyle}
          href={task.startUrl}
          actionAvailable
        >
          <React.Fragment>Unlock Task</React.Fragment>
        </TaskAction>
      )
    }
  }
}

class MyTask extends React.Component {
  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
  }

  render() {
    let task = this.props.task
    let filter = this.props.filter
    return (
      <React.Fragment>
        <Wrapper>
          <ExpandButton>
            {this.props.displayActions &&
              <a href={task.detailsUrl}><Icon name="expand-task.svg" /></a>
            }
            {!this.props.displayActions &&
              <Icon name="iconCloseCopy.svg" onClick={this.goBack} />
            }
          </ExpandButton>

          <Rows>
            <FirstRow>
              <Name>{task.name}</Name>
              <CurrencyAmount
                amount={task.totalAmount}
                currency={task.token.currency}
                logoUrl={task.token.logo}
              />
            </FirstRow>

            <SecondRow>
              {this.props.displayParents &&
                <BlockWrapper>
                  <Project>
                    PROJECT <a id="product-tour-my-tasks-step4" href={task.project.url}>{task.project.name}</a>
                    { this.props.displayFilters &&
                      <a href={location ? location.pathname + `?project_id=${task.project.id}` : ''}><Icon name="filter-2.svg" /></a>
                    }
                  </Project>

                  {task.mission.name &&
                    <Mission>MISSION <a href={task.mission.url}>{task.mission.name}</a></Mission>
                  }
                </BlockWrapper>
              }

              {this.props.displayActions &&
                <TaskActionComponent id="product-tour-my-tasks-step2" componentStyle="link" task={task} filter={filter} />
              }
            </SecondRow>

            <ThirdRow>
              <Status>
                <b>{task.status} </b>
                {task.updatedAt} ago
              </Status>

              {task.expiresAt &&
                <Status>
                  <b>EXPIRES IN </b>
                  {task.expiresAt}
                </Status>
              }

              <Type>
                <b>TYPE </b>
                {task.specialty || 'General'}
              </Type>

              {task.status !== 'ready' && task.contributor.name &&
                <Contributor>
                  <Userpics pics={[task.contributor.image]} limit={1} />
                  {task.contributor.name}
                </Contributor>
              }

              {task.status === 'ready' && task.contributor.name &&
                <Contributor>
                  <b>Invited By </b>
                  <Userpics pics={[task.issuer.image]} limit={1} />
                  {task.issuer.name}
                </Contributor>
              }

              {task.status === 'ready' && !task.contributor.name &&
                <ExperienceLevel>
                  <b>MINIMUM EXPERIENCE </b>
                  {task.experienceLevelName}
                </ExperienceLevel>
              }

              <TaskDetails id="product-tour-my-tasks-step1" displayActions={this.props.displayActions} href={this.props.displayActions ? task.detailsUrl : null}>
                View Task Details <Icon name="DROP_DOWN.svg" />
              </TaskDetails>

              {this.props.displayActions &&
                <TaskActionComponent componentStyle="button" task={task} filter={filter} />
              }
            </ThirdRow>
          </Rows>
        </Wrapper>
      </React.Fragment>
    )
  }
}

MyTask.propTypes = {
  task          : PropTypes.object,
  filter        : PropTypes.string,
  displayFilter : PropTypes.bool,
  displayActions: PropTypes.bool,
  displayParents: PropTypes.bool
}
MyTask.defaultProps = {
  task: {
    status: null,
    token : {
      currency : 'test',
      logo     : 'test',
      specialty: 'test'
    },
    project: {
      name: null,
      url : null
    },
    mission: {
      name: null,
      url : null
    },
    contributor: {
      name : null,
      image: null
    },
    policies: {
      start : true,
      submit: true,
      review: true,
      pay   : true
    },
    allowedToStart: true
  },
  displayFilters: false,
  displayActions: true,
  displayParents: true,
  filter        : ''
}
export default MyTask
