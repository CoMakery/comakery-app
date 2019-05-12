import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

const Layout = styled.div`
  background-color: white;
  padding: 25px 150px 25px 150px;
  min-height: 50vh;
  font-family: monospace;
`

const Header = styled.div`
`

const Filter = styled.div`
`

const Pagination = styled.div`
`

class MyTasks extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Layout>
          <Header />
          <Filter />
          <Pagination />

          {this.props.tasks.map(task =>
            <p key={task.id}>
              Name: {task.name}<br />
              Mission: {task.mission.name}<br />
              Project: {task.project.name}<br />
              Type: {task.batch.specialty}<br />
              Amount: {task.amount}<br />
              Status: {task.status}<br />
              Created By: {task.issuer.name}<br />
              Last Updated: {task.updatedAt}<br />
            </p>
          )}
          <p>
            Page: {this.props.pages.current}<br />
            Total: {this.props.pages.total}<br />
            {(this.props.pages.current !== this.props.pages.total) &&
              <React.Fragment>
                Next: <a href={`/tasks?page=${this.props.pages.current + 1}`}>{this.props.pages.current + 1}</a><br />
              </React.Fragment>
            }
            {(this.props.pages.current > 1) &&
              <React.Fragment>
                Prev: <a href={`/tasks?page=${this.props.pages.current - 1}`}>{this.props.pages.current - 1}</a><br />
              </React.Fragment>
            }
          </p>
        </Layout>
      </React.Fragment>
    )
  }
}

MyTasks.propTypes = {
  tasks: PropTypes.array.isRequired,
  pages: PropTypes.object.isRequired
}
MyTasks.defaultProps = {
  tasks: [],
  pages: {
    current: 1,
    total  : 1
  }
}
export default MyTasks
