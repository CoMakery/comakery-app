import React from 'react'
import PropTypes from 'prop-types'
import ProjectSetup from './layouts/ProjectSetup'
import InputFieldDropdown from './styleguide/InputFieldDropdown'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import SidebarItem from './styleguide/SidebarItem'
import ProfileModal from './ProfileModal'
import styled from 'styled-components'

const Title = styled.div`
  font-family: Montserrat;
  font-size: 16px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
  margin-bottom: 10px;
`

const Task = styled.div`
  font-family: Montserrat;
  font-size: 14px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-transform: uppercase;
  color: #3a3a3a;
  margin-bottom: 15px;
`

const Note = styled.div`
  font-family: Georgia;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.43;
  letter-spacing: normal;
  max-width: 556px;
  margin-bottom: 15px;
  text-align: justify;
`

const Link = styled.div`
  font-family: Georgia;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.43;
  letter-spacing: normal;
  max-width: 556px;
  margin-bottom: 15px;

  .input-field--title--required {
    display: none;
  }

  input {
    opacity: 1;
  }
`

const Warning = styled.div`
  font-family: Georgia;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.43;
  letter-spacing: normal;
  max-width: 556px;
  margin-bottom: 15px;
  text-align: justify;

  &::before {
    content: "Warning: ";
    font-weight: bold;
    color: #ff4d4d;
  }
`

const Profile = styled.div`
`

class TaskAssign extends React.Component {
  constructor(props) {
    super(props)

    this.goBack = this.goBack.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)

    this.state = {
      'account_id'     : null,
      interestedPresent: this.props.interested.length > 0
    }
  }

  goBack() {
    typeof window === 'undefined' ? null : window.location = document.referrer
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
    return (
      <React.Fragment>
        <ProjectSetup
          projectForHeader={this.props.projectForHeader}
          missionForHeader={this.props.missionForHeader}
          owner
          current="batches"
          hasBackButton
          subfooter={
            <React.Fragment>
              {this.state.interestedPresent &&
                <Button
                  value="send invitation"
                  type="submit"
                  form="task-assign-form"
                  data-disable="true"
                />
              }
              <ButtonBorder
                value="cancel"
                onClick={this.goBack}
              />
            </React.Fragment>
          }
          sidebar={
            <React.Fragment>
              <div className="batch-index--sidebar">
                <SidebarItem
                  className="batch-index--sidebar--item batch-index--sidebar--item__form"
                  text={this.props.batch.name}
                  selected
                />
                <hr className="batch-index--sidebar--hr" />
              </div>
            </React.Fragment>
          }
        >
          <Title>
            Assign a Contributor To Task
          </Title>

          <Task>
            {this.props.task.name}
          </Task>

          <Note>
            You can only invite CoMakery users that have expressed an interest or contributed in your project. If the person you would like to assign a task to is not on the picklist below, share your project URL with them, ask them to click “I’m Interested”, and you will then be able to choose them from the picklist below.
          </Note>

          {this.props.project['public?'] &&
            <Link>
              <InputFieldWhiteDark
                title="project link to share"
                readOnly
                copyOnClick
                value={this.props.project.url}
                symbolLimit={0}
              />
            </Link>
          }

          {!this.props.project['public?'] &&
            <Warning>
              This project is private. Change the project visibility in the project settings if you want to share the project's URL
            </Warning>
          }

          {this.state.interestedPresent &&
            <form id="task-assign-form" action={this.props.formUrl} encType="multipart/form-data" method="post">
              <InputFieldDropdown
                title="select user"
                name="account_id"
                required
                value={this.state.account_id}
                eventHandler={this.handleFieldChange}
                selectEntries={Object.entries(this.props.interestedSelect)}
              />

              {this.state.account_id &&
                <Profile>
                  <ProfileModal displayInline profile={this.props.interested.find(i => i.id.toString() === this.state.account_id)} />
                </Profile>
              }

              <input
                type="hidden"
                name="authenticity_token"
                value={this.props.csrfToken}
                readOnly
              />
            </form>
          }
        </ProjectSetup>
      </React.Fragment>
    )
  }
}
TaskAssign.propTypes = {
  task            : PropTypes.object.isRequired,
  batch           : PropTypes.object.isRequired,
  project         : PropTypes.object.isRequired,
  interested      : PropTypes.array.isRequired,
  interestedSelect: PropTypes.object.isRequired,
  formUrl         : PropTypes.string.isRequired,
  csrfToken       : PropTypes.string.isRequired,
  missionForHeader: PropTypes.object,
  projectForHeader: PropTypes.object
}
TaskAssign.defaultProps = {
  task: {
    'id'  : 28,
    'name': 'Dummy'
  },
  batch: {
    'id'  : 28,
    'name': 'Dummy'
  },
  project: {
    'id'     : 28,
    'title'  : 'Dummy',
    'url'    : 'http://dummy',
    'public?': true
  },
  interested      : [],
  interestedSelect: {},
  formUrl         : '/',
  csrfToken       : '00',
  missionForHeader: null,
  projectForHeader: null
}
export default TaskAssign
