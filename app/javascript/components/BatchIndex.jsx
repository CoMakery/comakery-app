import React from 'react'
import PropTypes from 'prop-types'
import ProjectSetup from './layouts/ProjectSetup'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'
import Batch from './Batch'
import Task from './Task'
import CurrencyAmount from './CurrencyAmount'
import styled, { css } from 'styled-components'
import * as Cookies from 'js-cookie'

const Wrapper = styled.div`
  margin-top: -20px;
`

const Text = styled.div`
  font-family: Georgia;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.29;
  letter-spacing: normal;

  ul {
    list-style-type: decimal;
  }

  a {
    color: #0089f4;
    text-decoration: none;
  }

  a:hover,
  a:focus {
    text-decoration: underline;
  }
`

const Title = styled.div`
  display: flex;
  align-items: center;
  margin-bottom: 7px;
  margin-top: 7px;
`

const FilterWrapper = styled.div`
  display: flex;
  align-items: center;
  margin-bottom: 7px;
  margin-top: 7px;
  margin-right: -15px;
  background: none;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  z-index: 200;

  &::-webkit-scrollbar {
    display: none;
  }
`

const TitleText = styled.div`
  margin-bottom: 3px;
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
`

const BatchStyled = styled(Batch)`
  margin-bottom: 20px;
`

const Filter = styled.span`
  margin-bottom: 3px;
  margin-right: 15px;
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
  color: #9b9b9b;

  &:hover {
    cursor: pointer;
    text-decoration: underline;
  }

  ${props => props.filter === 'ready' && props.selected && css`
    color: #4a4a4a;
  `}

  ${props => props.filter === 'started' && props.selected && css`
    color: #008e9b;
  `}

  ${props => props.filter === 'submitted' && props.selected && css`
    color: #007ae7;
  `}

  ${props => props.filter === 'accepted' && props.selected && css`
    color: #5037f7;
  `}

  ${props => props.filter === 'paid' && props.selected && css`
    color: #fb40e5;
  `}

  ${props => props.filter === 'rejected' && props.selected && css`
    color: #ff4d4d;
  `}

  ${props => props.filter === 'cancelled' && props.selected && css`
    color: #ff4d4d;
  `}

  ${props => !props.filter && props.selected && css`
    color: #3a3a3a;
  `}
`

const Tasks = styled.div`
  margin: 20px 0;
`

const CreateTaskButton = styled.div`
  font-family: Montserrat;
  font-size: 14px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-align: right;
  text-transform: uppercase;
  margin: 30px 0px;

  a {
    color: #0089f4;
    text-decoration: none;
  }

  a:hover,
  a:focus {
    text-decoration: underline;
  }
`

const ProjectBudget = styled.div`
  margin: 1em 0;
  margin-right: 1em;
`

const ProjectBudgetEntry = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  font-size: 14px;
  font-weight: 500;
  text-transform: uppercase;
  color: #3a3a3a;
  margin: 1em 0;
`

class BatchIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.state = {
      selectedBatch     : null,
      selectedTaskFilter: 'ready'
    }
  }

  componentDidMount() {
    this.setState({
      selectedBatch: this.props.batches.find(batch => String(batch.id) === Cookies.get('selectedBatchId')) || this.props.batches[0]
    })
  }

  handleListClick(batch) {
    this.setState({
      selectedBatch: batch
    })
    Cookies.set('selectedBatchId', batch.id)
  }

  notificationColor(batch) {
    switch (batch.state) {
      case 'public':
        return 'green'
      case 'invite only':
        return 'orange'
      case 'draft':
        return 'gray'
      default:
        return 'gray'
    }
  }

  render() {
    return (
      <React.Fragment>
        <ProjectSetup
          className="batch-index"
          projectForHeader={this.props.projectForHeader}
          missionForHeader={this.props.missionForHeader}
          owner={this.props.editable}
          current="batches"
          sidebar={
            <React.Fragment>
              <div className="batch-index--sidebar">

                {this.props.editable &&
                  <a href={this.props.newBatchPath}>
                    <SidebarItemBold
                      className="batch-index--sidebar--item__bold"
                      iconLeftName="BATCH/WHITE.svg"
                      iconRightName="PLUS.svg"
                      text="Create a New Batch"
                    />
                  </a>
                }

                <ProjectBudget>
                  {this.props.project.maximumTokens && this.props.project.maximumTokens > 0 &&
                    <ProjectBudgetEntry>
                      <div>planned budget</div>

                      <CurrencyAmount
                        amount={this.props.project.maximumTokens}
                        logoUrl={this.props.project.currencyLogo}
                      />
                    </ProjectBudgetEntry>
                  }

                  <ProjectBudgetEntry>
                    <div>allocated budget</div>

                    <CurrencyAmount
                      amount={this.props.project.allocatedBudget}
                      logoUrl={this.props.project.currencyLogo}
                    />
                  </ProjectBudgetEntry>
                </ProjectBudget>

                {this.props.batches.length > 0 &&
                  <React.Fragment>
                    <hr className="batch-index--sidebar--hr" />

                    <Title>
                      <TitleText>batches</TitleText>
                    </Title>

                    {this.props.batches.map((b, i) =>
                      <SidebarItem
                        className="batch-index--sidebar--item"
                        key={i}
                        text={b.name}
                        subchild={
                          <CurrencyAmount
                            amount={b.totalAmount}
                            logoUrl={b.currencyLogo}
                          />
                        }
                        notificationColor={this.notificationColor(b)}
                        selected={this.state.selectedBatch === b}
                        onClick={(_) => this.handleListClick(b)}
                      />
                    )}
                  </React.Fragment>
                }
              </div>
            </React.Fragment>
          }
        >
          {this.props.batches.length === 0 &&
            <Text>
              <ul>
                <li>Batches are “folders” that groups of similar tasks reside in.</li>
                <li>Projects can have one or many batches in them.</li>
                <li>A batch must be <a href={this.props.newBatchPath}>created</a> before a task can be created.</li>
              </ul>
            </Text>
          }
          {this.state.selectedBatch &&
            <React.Fragment>
              <Wrapper>
                <Title>
                  <TitleText>batch</TitleText>
                </Title>

                <BatchStyled batch={this.state.selectedBatch} editable={this.props.editable} />

                {this.props.editable &&
                  <CreateTaskButton>
                    <a href={this.state.selectedBatch.newTaskPath}>
                      create a task +
                    </a>
                  </CreateTaskButton>
                }

                <Tasks>
                  {this.state.selectedBatch.tasks.length > 0 &&
                    <FilterWrapper>
                      <Filter filter={this.state.selectedTaskFilter} selected={!this.state.selectedTaskFilter} onClick={(_) => this.setState({selectedTaskFilter: null})}>all&nbsp;tasks</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'ready'} onClick={(_) => this.setState({selectedTaskFilter: 'ready'})}>ready</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'started'} onClick={(_) => this.setState({selectedTaskFilter: 'started'})}>started</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'submitted'} onClick={(_) => this.setState({selectedTaskFilter: 'submitted'})}>submitted</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'accepted'} onClick={(_) => this.setState({selectedTaskFilter: 'accepted'})}>accepted</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'paid'} onClick={(_) => this.setState({selectedTaskFilter: 'paid'})}>paid</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'rejected'} onClick={(_) => this.setState({selectedTaskFilter: 'rejected'})}>rejected</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'cancelled'} onClick={(_) => this.setState({selectedTaskFilter: 'cancelled'})}>cancelled</Filter>
                    </FilterWrapper>
                  }
                  {this.state.selectedBatch.tasks.filter(task => !this.state.selectedTaskFilter || task.status === this.state.selectedTaskFilter || (this.state.selectedTaskFilter === 'ready' && task.status === 'invite ready')).map((t, i) =>
                    <Task editable={this.props.editable} key={i} task={t} />
                  )}
                </Tasks>
              </Wrapper>
            </React.Fragment>
          }
        </ProjectSetup>
      </React.Fragment>
    )
  }
}

BatchIndex.propTypes = {
  editable        : PropTypes.bool,
  batches         : PropTypes.array.isRequired,
  newBatchPath    : PropTypes.string,
  project         : PropTypes.object,
  missionForHeader: PropTypes.object,
  projectForHeader: PropTypes.object
}
BatchIndex.defaultProps = {
  editable        : true,
  batches         : [],
  newBatchPath    : '',
  project         : {},
  missionForHeader: null,
  projectForHeader: null
}
export default BatchIndex
