import React from 'react'
import PropTypes from 'prop-types'
import ProjectSetup from './layouts/ProjectSetup'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'
import Batch from './Batch'
import Task from './Task'
import styled, { css } from 'styled-components'

const Wrapper = styled.div`
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

const TitleText = styled.div`
  margin-bottom: 3px;
  font-size: 15px;
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
    color: #5037f7;
  `}

  ${props => props.filter === 'accepted' && props.selected && css`
    color: #7ed321;
  `}

  ${props => props.filter === 'paid' && props.selected && css`
    color: #fb40e5;
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

class BatchIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.state = {
      selectedBatch     : null,
      selectedTaskFilter: null
    }
  }

  handleListClick(batch) {
    this.setState({
      selectedBatch: batch
    })
  }

  render() {
    return (
      <React.Fragment>
        <ProjectSetup
          className="batch-index"
          projectId={this.props.project.id}
          projectTitle={this.props.project.title}
          projectPage="batches"
          sidebar={
            <React.Fragment>
              <div className="batch-index--sidebar">
                <SidebarItemBold
                  className="batch-index--sidebar--item__bold"
                  iconLeftName="BATCH/WHITE.svg"
                  iconRightName="PLUS.svg"
                  text="Create a New Batch"
                  onClick={(_) => window.location = this.props.newBatchPath}
                />

                {this.props.batches.length > 0 &&
                  <React.Fragment>
                    <hr className="batch-index--sidebar--hr" />

                    {this.props.batches.map((b, i) =>
                      <SidebarItem
                        className="batch-index--sidebar--item"
                        key={i}
                        iconLeftName="BATCH/ACTIVE.GRADIENT.svg"
                        text={b.name}
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

                <BatchStyled batch={this.state.selectedBatch} />

                <Tasks>
                  {this.state.selectedBatch.tasks.length > 0 &&
                    <Title>
                      <Filter filter={this.state.selectedTaskFilter} selected={!this.state.selectedTaskFilter} onClick={(_) => this.setState({selectedTaskFilter: null})}>all tasks</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'ready'} onClick={(_) => this.setState({selectedTaskFilter: 'ready'})}>ready</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'accepted'} onClick={(_) => this.setState({selectedTaskFilter: 'accepted'})}>accepted</Filter>
                      <Filter filter={this.state.selectedTaskFilter} selected={this.state.selectedTaskFilter === 'paid'} onClick={(_) => this.setState({selectedTaskFilter: 'paid'})}>paid</Filter>
                    </Title>
                  }
                  {this.state.selectedBatch.tasks.filter(task => !this.state.selectedTaskFilter || task.status === this.state.selectedTaskFilter).map((t, i) =>
                    <Task key={i} task={t} />
                  )}
                </Tasks>

                <CreateTaskButton>
                  <a href={this.state.selectedBatch.newTaskPath}>
                    create a task +
                  </a>
                </CreateTaskButton>
              </Wrapper>
            </React.Fragment>
          }
        </ProjectSetup>
      </React.Fragment>
    )
  }
}

BatchIndex.propTypes = {
  batches     : PropTypes.array.isRequired,
  newBatchPath: PropTypes.string,
  project     : PropTypes.object
}
BatchIndex.defaultProps = {
  batches     : [],
  newBatchPath: '',
  project     : {}
}
export default BatchIndex
