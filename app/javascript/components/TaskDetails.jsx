import React from 'react'
import PropTypes from 'prop-types'
import MyTask from './MyTask'
import ContentBlock from './ContentBlock'
import BackButton from './BackButton'
import Button from './styleguide/Button'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescriptionMiddle from './styleguide/InputFieldDescriptionMiddle'
import styled from 'styled-components'

const Wrapper = styled.div`
  background-color: white;
`

const Layout = styled.div`
  padding: 25px 150px 25px 150px;
  min-height: 50vh;
  margin-top: -110px;

  @media (max-width: 1024px) {
    padding: 25px 15px 25px 15px;
  }
`

const HeaderWrapper = styled.div`
  background-color: white;
`

const Header = styled.div`
  height: 140px;
  background-image: url(${require(`src/images/tasks/header_background_w_opacity.jpg`)});
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

const SubHeader = styled.h2`
  text-transform: uppercase;
  margin-top: 0;
  margin-bottom: 20px;
  font-family: Montserrat;
  font-size: 18px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
`

const Details = styled.div`
  padding: 30px 40px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  background-color: #ffffff;
  margin-top: -9px;
  margin-bottom: 10px;

  img {
    max-width: 80px;
    max-height: 80px;
    border: 1px solid transparent;

    &:hover {
      border: 1px solid #0089f4;
    }
  }
`

const Submission = styled.div`
  padding: 30px 40px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  background-color: #ffffff;
  margin-top: -9px;
  margin-bottom: 10px;
`

const Review = styled.div`
  padding: 30px 40px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  background-color: #ffffff;
  margin-top: -9px;
  margin-bottom: 10px;

  a {
    color: #0089f4;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }

  form {
    display: inline;
  }
`

class TaskDetails extends React.Component {
  constructor(props) {
    super(props)

    this.errorAdd = this.errorAdd.bind(this)
    this.errorRemove = this.errorRemove.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)

    this.state = {
      errors: {}
    }
  }

  errorAdd(n, e) {
    this.setState({
      errors: Object.assign({}, this.state.errors, {[n]: e})
    })
  }

  errorRemove(n) {
    let e = this.state.errors
    delete e[n]
    this.setState({
      errors: e
    })
  }

  handleFieldChange(event) {
    this.setState({ [event.target.name]: event.target.value })

    if (!event.target.checkValidity()) {
      this.errorAdd(event.target.name, 'invalid value')
      return
    } else {
      this.errorRemove(event.target.name)
    }

    if (event.target.value === '') {
      return
    }
  }

  render() {
    let task = this.props.task

    return (
      <React.Fragment>
        <Wrapper>
          <HeaderWrapper>
            <Header />
          </HeaderWrapper>

          <BackButton />

          <Layout>
            <MyTask task={task} displayActions={false} />

            {task.status === 'started' &&
              <Submission>
                <SubHeader>
                  Task Submission
                </SubHeader>

                <form action={task.submitUrl} method="post">
                  <InputFieldWhiteDark
                    title="URL Where Completed Work Can Be Viewed"
                    required
                    name="task[submission_url]"
                    value={this.state['task[submission_url]']}
                    eventHandler={this.handleFieldChange}
                    errorText={this.state.errors['task[submission_url]']}
                    placeholder="Provide a URL"
                    symbolLimit={150}
                  />

                  <InputFieldDescriptionMiddle
                    title="Additional Comments"
                    required
                    name="task[submission_comment]"
                    value={this.state['task[submission_comment]']}
                    eventHandler={this.handleFieldChange}
                    errorText={this.state.errors['task[submission_comment]']}
                    placeholder="Provide any required comments"
                    symbolLimit={500}
                  />

                  <input
                    type="hidden"
                    name="authenticity_token"
                    value={this.props.csrfToken}
                    readOnly
                  />

                  <Button
                    type="submit"
                    value="submit task"
                  />
                </form>
              </Submission>
            }

            {task.submissionUrl && task.submissionComment &&
              <Review>
                <SubHeader>
                  Submitted Work
                </SubHeader>

                <ContentBlock title="URL WHERE COMPLETED WORK CAN BE VIEWED">
                  <a target="_blank" href={task.submissionUrl}>
                    {task.submissionUrl}
                  </a>
                </ContentBlock>

                <ContentBlock title="ADDITIONAL COMMENTS">
                  {task.submissionComment}
                </ContentBlock>

                {task.status === 'submitted' && task.issuer.self &&
                  <React.Fragment>
                    <form action={task.acceptUrl} method="post">
                      <input
                        type="hidden"
                        name="authenticity_token"
                        value={this.props.csrfToken}
                        readOnly
                      />
                      <Button
                        type="submit"
                        value="accept"
                      />
                    </form>

                    <form action={task.rejectUrl} method="post">
                      <input
                        type="hidden"
                        name="authenticity_token"
                        value={this.props.csrfToken}
                        readOnly
                      />
                      <Button
                        type="submit"
                        value="reject & end"
                      />
                    </form>
                  </React.Fragment>
                }
              </Review>
            }

            <Details>
              <SubHeader>
                Task Details
              </SubHeader>

              <ContentBlock title="what is the expected benefit">
                {task.why}
              </ContentBlock>

              <ContentBlock title="description">
                {task.description}
              </ContentBlock>

              {task.imageUrl &&
                <ContentBlock>
                  <a target="_blank" href={task.imageUrl}>
                    <img src={task.imageUrl} />
                  </a>
                </ContentBlock>
              }

              <ContentBlock title="acceptance criterias">
                {task.requirements}
              </ContentBlock>

              {task.status === 'ready' &&
                <form action={task.startUrl} method="post">
                  <input
                    type="hidden"
                    name="authenticity_token"
                    value={this.props.csrfToken}
                    readOnly
                  />
                  <Button
                    type="submit"
                    value="start task"
                  />
                </form>
              }
            </Details>
          </Layout>
        </Wrapper>
      </React.Fragment>
    )
  }
}

TaskDetails.propTypes = {
  task: PropTypes.object
}
TaskDetails.defaultProps = {
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
export default TaskDetails
