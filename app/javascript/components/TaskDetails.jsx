import React from 'react'
import PropTypes from 'prop-types'
import MyTask from './MyTask'
import ContentBlock from './ContentBlock'
import Button from './styleguide/Button'
import ButtonBorderGray from './styleguide/ButtonBorderGray'
import Icon from './styleguide/Icon'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescriptionMiddle from './styleguide/InputFieldDescriptionMiddle'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import styled from 'styled-components'

const Wrapper = styled.div`
  background-color: white;
`

const Layout = styled.div`
  padding: 25px 150px 25px 150px;
  min-height: 50vh;
  max-width: 980px;
  margin: auto;
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
  margin-top: -19px;
  margin-bottom: 20px;

  img {
    max-width: 80px;
    max-height: 80px;
    border: 1px solid transparent;

    &:hover {
      border: 1px solid #0089f4;
    }
  }
`

const LockedMessage = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  font-family: Georgia;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #4a4a4a;

  img {
    margin-right: 0.5em;

    &:hover {
      border: 1px solid transparent;
    }
  }

  a {
    color: #0089f4;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
`

const Channel = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-top: 7px;
  font-family: Montserrat;
  font-size: 12px;
  font-weight: bold;
  color: #3a3a3a;
  text-transform: uppercase;

  img {
    max-width: 20px;
    max-height: 20px;
    border: none;
    margin-right: 7px;

    &:hover {
      border: none;
    }
  }

  a {
    text-decoration: none;
    text-transform: none;
    font-family: Georgia;
    font-size: 14px;
    font-weight: 500;
    color: #0089f4;

    &:hover {
      text-decoration: underline;
    }
  }
`

const Submission = styled.div`
  padding: 30px 40px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  background-color: #ffffff;
  margin-top: -19px;
  margin-bottom: 20px;
`

const Review = styled.div`
  padding: 30px 40px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  background-color: #ffffff;
  margin-top: -19px;
  margin-bottom: 20px;

  a {
    color: #0089f4;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }

  img {
    max-width: 80px;
    max-height: 80px;
    border: 1px solid transparent;

    &:hover {
      border: 1px solid #0089f4;
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

  goBack() {
    typeof window === 'undefined' ? null : window.location = document.referrer
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

          <Layout>
            <MyTask task={task} displayActions={false} />

            {task.status === 'started' &&
              <Submission>
                <SubHeader>
                  Task Submission
                </SubHeader>

                <form action={task.submitUrl} encType="multipart/form-data" method="post">
                  <InputFieldWhiteDark
                    title="URL Where Completed Work Can Be Viewed"
                    required
                    name="task[submission_url]"
                    value={this.state['task[submission_url]']}
                    eventHandler={this.handleFieldChange}
                    errorText={this.state.errors['task[submissionUrl]']}
                    placeholder="Provide a URL"
                    symbolLimit={150}
                  />

                  <InputFieldDescriptionMiddle
                    title="Additional Comments"
                    required
                    name="task[submission_comment]"
                    value={this.state['task[submission_comment]']}
                    eventHandler={this.handleFieldChange}
                    errorText={this.state.errors['task[submissionComment]']}
                    placeholder="Provide any required comments"
                    symbolLimit={500}
                  />

                  <InputFieldUploadFile
                    title="Image attachement"
                    name="task[submission_image]"
                    errorText={this.state.errors['task[submissionImage]']}
                    imgPreviewUrl={this.props.task.submissionImageUrl}
                    imgPreviewDimensions="100x100"
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

                  <ButtonBorderGray
                    onClick={this.goBack}
                    value="cancel"
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

                {task.submissionImageUrl &&
                  <ContentBlock title="ATTACHED IMAGE">
                    <a target="_blank" href={task.submissionImageUrl}>
                      <img src={task.submissionImageUrl} />
                    </a>
                  </ContentBlock>
                }

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
                      <ButtonBorderGray
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
                <div dangerouslySetInnerHTML={{__html: task.descriptionHtml}} />
              </ContentBlock>

              {task.imageUrl &&
                <ContentBlock>
                  <a target="_blank" href={task.imageUrl}>
                    <img src={task.imageUrl} />
                  </a>
                </ContentBlock>
              }

              <ContentBlock title="acceptance criteria">
                <div dangerouslySetInnerHTML={{__html: task.requirementsHtml}} />
              </ContentBlock>

              {task.project.channels.length > 0 &&
                <ContentBlock title="chat with the project owner">
                  {task.project.channels.map(channel =>
                    <Channel key={channel.id}>
                      <Icon name={`channel_${channel.type}.svg`} />
                      <a target="_blank" href={channel.url}>{channel.url}</a>
                    </Channel>
                  )}
                </ContentBlock>
              }

              {task.status === 'ready' &&
                <React.Fragment>
                  {this.props.taskAllowedToStart &&
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

                      <ButtonBorderGray
                        onClick={this.goBack}
                        value="cancel"
                      />
                    </form>
                  }

                  {!this.props.taskAllowedToStart &&
                    <LockedMessage>
                      <Icon name="NO-SKILLS.svg" />
                      <div>
                        This task has experince level requirement – {task.experienceLevelName}.
                        Unlock access by completing <b>{this.props.tasksToUnlock}</b> more {task.batch.specialty || 'General'} {this.props.tasksToUnlock === 1 ? 'task' : 'tasks'} available to you in <a href={this.props.myTasksPath}>My Tasks</a>.
                      </div>
                    </LockedMessage>
                  }
                </React.Fragment>
              }
            </Details>
          </Layout>
        </Wrapper>
      </React.Fragment>
    )
  }
}

TaskDetails.propTypes = {
  task              : PropTypes.object,
  taskAllowedToStart: PropTypes.bool,
  tasksToUnlock     : PropTypes.number,
  myTasksPath       : PropTypes.string
}
TaskDetails.defaultProps = {
  task: {
    status: null,
    token : {
      currency: 'test',
      logo    : 'test'
    },
    project: {
      name    : null,
      url     : null,
      channels: []
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
  },
  taskAllowedToStart: true,
  tasksToUnlock     : 0,
  myTasksPath       : '/'
}
export default TaskDetails
