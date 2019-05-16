import React from 'react'
import PropTypes from 'prop-types'
import MyTask from './MyTask'
import styled from 'styled-components'

const Layout = styled.div`
  background-color: white;
  padding: 25px 150px 25px 150px;
  min-height: 50vh;

  @media (max-width: 1024px) {
    padding: 25px 15px 25px 15px;
  }
`

const Header = styled.div`
  height: 140px;
  background-image: url(${require(`src/images/tasks/header_background.jpg`)});
  background-position: center;
  font-family: Montserrat;
  font-size: 30px;
  font-weight: 900;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-align: center;
  color: #ffffff;
  text-transform: uppercase;
  display: flex;
  flex-direction: column;
  justify-content: center;
`

const Filter = styled.div`
`

const Pagination = styled.div`
`

class MyTasks extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Header>
          My Tasks
        </Header>
        <Layout>
          <Filter />
          <Pagination />

          {this.props.tasks.map(task =>
            <MyTask key={task.id} task={task} />
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
