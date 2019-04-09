import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'
import Icon from './styleguide/Icon'

class BatchIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.state = {
      selectedBatch: null
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
        <Layout
          className="batch-index"
          navTitle={[
            {
              name: 'project settings',
              url : this.props.projectEditPath
            },
            {
              name   : 'batches',
              current: true
            }
          ]}
          sidebar={
            <React.Fragment>
              <div className="batch-index--sidebar">
                <SidebarItemBold
                  className="batch-index--sidebar--item__bold"
                  iconLeftName="BATCH/WHITE.svg"
                  iconRightName="PLUS.svg"
                  text="Create a New Batch"
                  onClick={(_) => window.location = `${window.location}/new`}
                />

                { this.props.batches.length > 0 &&
                  <React.Fragment>
                    <hr />

                    <div className="batch-index--sidebar--info">
                      Please select batch:
                    </div>

                    {this.props.batches.map((b, i) =>
                      <SidebarItem
                        className="batch-index--sidebar--item"
                        key={i}
                        iconLeftName="BATCH/WHITE.svg"
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
          {this.state.selectedBatch &&
            <React.Fragment>
              <div>
                BATCH
              </div>

              <div className="batch-index--view">
                <div className="batch-index--view--name">
                  {this.state.selectedBatch.name}
                </div>

                <div className="batch-index--view--specialty">
                  {this.state.selectedBatch.specialtyId}
                </div>

                <div className="batch-index--view--team-members" />

                <div className="batch-index--view--edit">
                  <a href={this.state.selectedBatch.editPath}>
                    <Icon name="iconEdit.svg" />
                  </a>
                </div>

                <div className="batch-index--view--delete">
                  <a rel="nofollow" data-method="delete" href={this.state.selectedBatch.destroyPath}>
                    <Icon name="iconTrash.svg" />
                  </a>
                </div>
              </div>

              <div>
                TASKS
              </div>

              <div className="batch-index--tasks">
                {this.state.selectedBatch.tasks.map((t, i) =>
                  <div key={i} className="batch-index--tasks--task">
                    <div className="batch-index--tasks--task--name">
                      {t.name}
                    </div>
                    <div className="batch-index--tasks--task--amount">
                      {`${t.amount} ${t.tokenSymbol}`}
                    </div>
                    <div className="batch-index--tasks--task--award">
                      {t.status !== 'done' &&
                        <a href={t.awardPath}>
                          Pay
                        </a>
                      }
                    </div>
                    <div className="batch-index--tasks--task--edit">
                      <a href={t.editPath}>
                        <Icon name="iconEdit.svg" />
                      </a>
                    </div>
                    <div className="batch-index--tasks--task--delete">
                      <a rel="nofollow" data-method="delete" href={t.destroyPath}>
                        <Icon name="iconTrash.svg" />
                      </a>
                    </div>
                  </div>
                )}
              </div>

              <div className="batch-index--create-task">
                <a href={this.state.selectedBatch.newTaskPath}>
                  Create a Task
                </a>
              </div>
            </React.Fragment>
          }
        </Layout>
      </React.Fragment>
    )
  }
}

BatchIndex.propTypes = {
  batches  : PropTypes.array.isRequired,
  projectId: PropTypes.number
}
BatchIndex.defaultProps = {
  batches  : [],
  projectId: null
}
export default BatchIndex
