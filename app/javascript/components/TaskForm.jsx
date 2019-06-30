import React from 'react'
import PropTypes from 'prop-types'
import ProjectSetup from './layouts/ProjectSetup'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescription from './styleguide/InputFieldDescription'
import InputFieldDescriptionMiddle from './styleguide/InputFieldDescriptionMiddle'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import InputFieldDropdown from './styleguide/InputFieldDropdown'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'
import SidebarItem from './styleguide/SidebarItem'

class TaskForm extends React.Component {
  constructor(props) {
    super(props)

    this.errorAdd = this.errorAdd.bind(this)
    this.errorRemove = this.errorRemove.bind(this)
    this.disable = this.disable.bind(this)
    this.enable = this.enable.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)

    this.state = {
      flashMessages                         : [],
      errors                                : {},
      disabled                              : {},
      formAction                            : this.props.formAction,
      formUrl                               : this.props.formUrl,
      closeOnSuccess                        : false,
      'task[name]'                          : this.props.task.name || '',
      'task[why]'                           : this.props.task.why || '',
      'task[description]'                   : this.props.task.description || '',
      'task[requirements]'                  : this.props.task.requirements || '',
      'task[experience_level]'              : this.props.task.experienceLevel || '',
      'task[amount]'                        : this.props.task.amount || '',
      'task[number_of_assignments]'         : this.props.task.numberOfAssignments || 1,
      'task[number_of_assignments_per_user]': this.props.task.numberOfAssignmentsPerUser || 1,
      'task[specialty_id]'                  : this.props.task.specialtyId || Object.values(this.props.specialties)[0],
      'task[proof_link]'                    : this.props.task.proofLink || ''
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

  disable(a) {
    let d = this.state.disabled
    a.forEach(n => d = Object.assign({}, d, {[n]: true}))
    this.setState({
      disabled: d
    })
  }

  enable(a) {
    let d = this.state.disabled
    a.forEach(n => delete d[n])
    this.setState({
      disabled: d
    })
  }

  handleFieldChange(event) {
    this.setState({ [event.target.name]: event.target.value })

    if (event.target.name === 'task[number_of_assignments]' && event.target.value === '1') {
      this.setState({ 'task[number_of_assignments_per_user]': '1' })
    }

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

  handleSubmit(event) {
    event.preventDefault()

    this.disable(['task[submit]', 'task[submit_and_close]'])

    if (!event.target.checkValidity()) {
      this.enable(['task[submit]', 'task[submit_and_close]'])
      return
    }

    const formData = new FormData(event.target)

    fetchPolyfill(this.state.formUrl, {
      credentials: 'same-origin',
      method     : this.state.formAction,
      body       : formData,
      headers    : {
        'X-Key-Inflection': 'snake'
      }
    }).then(response => {
      if (response.status === 200) {
        if (this.state.closeOnSuccess) {
          window.location = this.props.urlOnSuccess
        } else {
          response.json().then(data => {
            if (this.state.formAction === 'POST') {
              this.setState(state => ({
                formAction   : 'PUT',
                formUrl      : data.formUrl,
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': data.message}])
              }))
              history.replaceState(
                {},
                document.title,
                `${window.location.origin}${data.editUrl}`
              )
            } else {
              this.setState(state => ({
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': data.message}])
              }))
            }
          })
          this.enable(['task[submit]', 'task[submit_and_close]'])
        }
      } else {
        response.json().then(data => {
          this.setState(state => ({
            errors       : data.errors,
            flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': data.message}])
          }))
          this.enable(['task[submit]', 'task[submit_and_close]'])
        })
      }
    })
  }

  render() {
    return (
      <React.Fragment>
        <ProjectSetup
          className="task-form"
          projectId={this.props.project.id}
          projectTitle={this.props.project.title}
          projectPage="batches"
          hasBackButton
          subfooter={
            <React.Fragment>
              <Button
                value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
                type="submit"
                form="task-form--form"
                disabled={this.state.disabled['task[submit_and_close]']}
                onClick={() => this.setState({closeOnSuccess: true})}
              />
              <ButtonBorder
                value={this.state.formAction === 'POST' ? 'create' : 'save'}
                type="submit"
                form="task-form--form"
                disabled={this.state.disabled['task[submit]']}
                onClick={() => this.setState({closeOnSuccess: false})}
              />
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
                  iconLeftName="BATCH/ACTIVE.GRADIENT.svg"
                  text={this.props.batch.name}
                  selected
                />
                <hr className="batch-index--sidebar--hr" />
              </div>
            </React.Fragment>
          }
        >
          <Flash messages={this.state.flashMessages} />

          <div className="task-form--form--title">
            {this.state.formAction === 'POST' ? 'Create a New Task' : 'Edit Task'}
          </div>

          <form className="task-form--form" id="task-form--form" onSubmit={this.handleSubmit}>
            <InputFieldWhiteDark
              title="name"
              required
              name="task[name]"
              value={this.state['task[name]']}
              errorText={this.state.errors['task[name]']}
              eventHandler={this.handleFieldChange}
              placeholder="Provide a clear title for the Task"
              symbolLimit={100}
            />

            <InputFieldDescriptionMiddle
              title="why"
              required
              name="task[why]"
              value={this.state['task[why]']}
              errorText={this.state.errors['task[why]']}
              eventHandler={this.handleFieldChange}
              placeholder="Let people know what will be the result of this task being completed (ex: When task is finished, the result will be xxxx)"
              symbolLimit={500}
            />

            <InputFieldDescriptionMiddle
              title="description"
              required
              name="task[description]"
              value={this.state['task[description]']}
              errorText={this.state.errors['task[description]']}
              eventHandler={this.handleFieldChange}
              placeholder="Provide a longer description about the task, the type of work involved, and how it will relate to the larger batch"
              symbolLimit={500}
            />

            <InputFieldUploadFile
              title="image asset to help guide the task"
              name="task[image]"
              errorText={this.state.errors['task[image]']}
              imgPreviewUrl={this.props.task.imageUrl}
              imgPreviewDimensions="100x100"
            />

            {this.props.task.imageFromId &&
              <input
                type="hidden"
                name="task[image_from_id]"
                value={this.props.task.imageFromId}
                readOnly
              />
            }

            <InputFieldDescription
              title="acceptance requirements"
              required
              name="task[requirements]"
              value={this.state['task[requirements]']}
              errorText={this.state.errors['task[requirements]']}
              eventHandler={this.handleFieldChange}
              placeholder="This section is free text that allows for the use of markdown. Create bullets using an asterick and a space before each sentence. Make sure to list a bullet point for each acceptance criteria. These bullet points will be used by reviewers to verify the work."
              symbolLimit={750}
            />

            <InputFieldDropdown
              title="specialty"
              required
              name="task[specialty_id]"
              value={this.state['task[specialty_id]']}
              errorText={this.state.errors['task[specialtyId]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.specialties)}
              symbolLimit={0}
            />

            <InputFieldDropdown
              title="skill confirmations required"
              required
              name="task[experience_level]"
              value={this.state['task[experience_level]']}
              errorText={this.state.errors['task[experienceLevel]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.experienceLevels)}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title={`award amount (${this.props.token.symbol || 'no token'})`}
              required
              name="task[amount]"
              value={this.state['task[amount]']}
              errorText={this.state.errors['task[amount]']}
              eventHandler={this.handleFieldChange}
              type="number"
              min="0"
              step={`${1.0 / (10 ** this.props.token.decimalPlaces)}`}
              placeholder="The total amount of tokens or coins you are paying for this task to be completed"
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="how many times can this task be done"
              required
              name="task[number_of_assignments]"
              value={this.state['task[number_of_assignments]']}
              errorText={this.state.errors['task[numberOfAssignments]']}
              eventHandler={this.handleFieldChange}
              type="number"
              min="1"
              step="1"
              placeholder="1"
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="how many times can this task be done by a single user"
              required
              name="task[number_of_assignments_per_user]"
              value={this.state['task[number_of_assignments_per_user]']}
              errorText={this.state.errors['task[numberOfAssignmentsPerUser]']}
              eventHandler={this.handleFieldChange}
              type="number"
              readOnly={this.state['task[number_of_assignments]'] === '1'}
              min="1"
              step="1"
              placeholder="1"
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="URL where to submit completed work"
              required
              name="task[proof_link]"
              value={this.state['task[proof_link]']}
              errorText={this.state.errors['task[proofLink]']}
              eventHandler={this.handleFieldChange}
              placeholder="URL to a Dropbox or Drive Folder, or a GitHub Repo (http://example.com)"
              symbolLimit={150}
            />

            <input
              type="hidden"
              name="authenticity_token"
              value={this.props.csrfToken}
              readOnly
            />
          </form>
        </ProjectSetup>
      </React.Fragment>
    )
  }
}

TaskForm.propTypes = {
  task            : PropTypes.object.isRequired,
  batch           : PropTypes.object.isRequired,
  project         : PropTypes.object.isRequired,
  token           : PropTypes.object.isRequired,
  experienceLevels: PropTypes.object.isRequired,
  specialties     : PropTypes.object.isRequired,
  formUrl         : PropTypes.string.isRequired,
  formAction      : PropTypes.string.isRequired,
  urlOnSuccess    : PropTypes.string.isRequired,
  csrfToken       : PropTypes.string.isRequired
}
TaskForm.defaultProps = {
  task            : {'default': '_'},
  batch           : {'default': '_'},
  project         : {'default': '_'},
  token           : {'default': '_'},
  experienceLevels: {'default': '_'},
  specialties     : {'default': '_'},
  formUrl         : '/',
  formAction      : 'POST',
  urlOnSuccess    : '/',
  csrfToken       : '00'
}
export default TaskForm
