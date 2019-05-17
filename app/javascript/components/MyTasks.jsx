import React from 'react'
import PropTypes from 'prop-types'
import MyTask from './MyTask'
import styled, {css} from 'styled-components'

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
  background-size: cover;
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

const PastAwards = styled.div`
  text-align: right;
  width: 100%;

  a {
    font-family: Montserrat;
    font-size: 12px;
    font-weight: bold;
    font-style: normal;
    font-stretch: normal;
    line-height: normal;
    letter-spacing: normal;
    color: #0089f4;
    text-decoration: none;
    text-transform: uppercase;

    &:hover {
      text-decoration: underline;
    }
  }
`

const Filter = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  margin: 25px 0;
  flex-wrap: wrap;

  @media (max-width: 1024px) {
    justify-content: center;
  }
`

const FilterLink = styled.a`
  text-transform: uppercase;
  font-family: Montserrat;
  font-size: 14px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-align: center;
  color: #8d9599;
  text-decoration: none;
  padding: 5px;
  line-height: 1.5;

  &:hover {
    text-decoration: underline;
  }

  ${props => props.current && css`
    color: #0089f4;
    border-bottom: 2px solid #0089f4;
  `}
`

const Pagination = styled.div`
  text-align: right;
  width: 100%;
  padding: 15px 0;
  border-bottom: 1px solid #d8d8d8;
  margin-bottom: 35px;
`

class MyTasks extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Header>
          My Tasks
        </Header>

        <Layout>
          <PastAwards>
            <a href={this.props.pastAwardsUrl}>See past awards</a>
          </PastAwards>

          <Filter>
            {this.props.filters.map(filter =>
              <FilterLink key={filter.name} href={filter.url} current={filter.current}>
                {filter.name}
                <br />
                {filter.count}
              </FilterLink>
            )}
          </Filter>

          <Pagination dangerouslySetInnerHTML={{__html: this.props.paginationHtml}} />

          {this.props.tasks.map(task =>
            <MyTask key={task.id} task={task} />
          )}
        </Layout>
      </React.Fragment>
    )
  }
}

MyTasks.propTypes = {
  tasks         : PropTypes.array.isRequired,
  filters       : PropTypes.array.isRequired,
  paginationHtml: PropTypes.string.isRequired,
  pastAwardsUrl : PropTypes.string.isRequired
}
MyTasks.defaultProps = {
  tasks         : [],
  filters       : [],
  paginationHtml: '',
  pastAwardsUrl : ''
}
export default MyTasks
