import React from 'react'
import PropTypes from 'prop-types'
import CurrencyAmount from './CurrencyAmount'
import Userpics from './Userpics'
import styled, { css } from 'styled-components'

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  height: 80px;
  padding: 10px 20px;
  margin-bottom: 10px;
  text-transform: uppercase;
`

const RightBorder = styled.div`
  width: 2px;
  height: 100px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, .2);
  background-color: #5037f7;
  z-index: 10;
  position: absolute;
  margin-left: -21px;
  margin-top: -10px;

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

const FirstRow = styled.div`
  margin-bottom: 10px;
  display: flex;
  width: 100%;
  justify-content: space-between;
  align-items: flex-start;
`

const SecondRow = styled.div`
  min-height: 28px;
  margin-bottom: 12px;
  display: flex;
  width: 100%;
  justify-content: space-between;
`

const ThirdRow = styled.div`
  display: flex;
  width: 100%;
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
`

const BlockWrapper = styled.div`
  margin-right: auto;
`

const Mission = styled.div`
  font-family: Montserrat;
  font-size: 12px;
  font-weight: 600;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.4;
  letter-spacing: normal;
  color: #4a4a4a;
  text-transform: none;

  a {
    text-decoration: none;
    color: #0089f4;

    &:hover {
      text-decoration: underline;
    }
  }
`

const Project = styled.div`
  font-family: Montserrat;
  font-size: 12px;
  font-weight: 600;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.4;
  letter-spacing: normal;
  color: #4a4a4a;
  text-transform: none;

  a {
    text-decoration: none;
    color: #0089f4;

    &:hover {
      text-decoration: underline;
    }
  }
`

const Status = styled.div`
  font-family: Montserrat;
  font-size: 10px;
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

class MyTask extends React.Component {
  render() {
    let task = this.props.task
    return (
      <React.Fragment>
        <Wrapper>
          <RightBorder status={task.status} />
          <FirstRow>
            <Name>{task.name}</Name>
            <CurrencyAmount
              amount={task.totalAmount}
              currency={task.token.currency}
              logoUrl={task.token.logo}
            />
          </FirstRow>

          <SecondRow>
            <BlockWrapper>
              <Project>PROJECT: <a href={task.project.url}>{task.project.name}</a></Project>
              {task.mission.name &&
                <Mission>MISSION: <a href={task.mission.url}>{task.mission.name}</a></Mission>
              }
            </BlockWrapper>
          </SecondRow>

          <ThirdRow>
            <Status>
              <b>{task.status} </b>
              {task.updatedAt} ago
            </Status>
            <Type>
              <b>TYPE </b>
              {task.batch.specialty || 'General'}
            </Type>
            {task.contributor.name &&
              <Contributor>
                <Userpics pics={[task.contributor.image]} limit={1} />
                {task.contributor.name}
              </Contributor>
            }
          </ThirdRow>
        </Wrapper>
      </React.Fragment>
    )
  }
}

MyTask.propTypes = {
  task: PropTypes.object
}
MyTask.defaultProps = {
  task: {
    status: null,
    token : {
      currency: 'test',
      logo    : 'test'
    },
    project: {
      name: null,
      url : null
    },
    mission: {
      name: null,
      url : null
    },
    batch: {
      specialty: null
    },
    contributor: {
      name : null,
      image: null
    }
  }
}
export default MyTask
