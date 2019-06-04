import React from 'react'
import PropTypes from 'prop-types'
import MyTask from './MyTask'
import styled, {css} from 'styled-components'

const Wrapper = styled.div`
  background-color: white;
`

const Layout = styled.div`
  background-color: white;
  padding: 25px 150px 25px 150px;
  min-height: 50vh;
  max-width: 980px;
  margin: auto;

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
  background-color: #ffffff;

  @media (max-width: 1024px) {
    background: none;
    position: sticky;
    top: 25px;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    margin: 0 -15px;
    padding: 10px;
    z-index: 200;
  }

  &::-webkit-scrollbar {
    display: none;
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
  line-height: 1.5;
  min-width: 100px;
  padding: 5px;

  &:hover {
    text-decoration: underline;
  }

  ${props => props.current && css`
    color: #0089f4;
    border-bottom: 2px solid #0089f4;
  `}

  @media (max-width: 1024px) {
    background-color: #ffffff;
    box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
    flex: 0 0 auto;
    margin-right: 20px;
  }
`

const Pagination = styled.div`
  text-align: right;
  width: 100%;
  padding: 15px 0;
  border-bottom: 1px solid #d8d8d8;
  margin-bottom: 35px;
`

class MyTasks extends React.Component {
  constructor(props) {
    super(props)
    this.state = { ready: false }
  }

  componentDidMount() {
    this.setState({ ready: true })
  }

  render() {
    if (!this.state.ready) {
      return (
        <div className="loading-placeholder" />
      )
    }
    return (
      <React.Fragment>
        <Wrapper>
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
              <MyTask key={task.id} task={task} filter={this.props.filters.find(f => f.current).name} />
            )}
          </Layout>
        </Wrapper>
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
