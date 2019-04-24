import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescription from './styleguide/InputFieldDescription'
import InputFieldDescriptionMiddle from './styleguide/InputFieldDescriptionMiddle'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'

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
      flashMessages       : [],
      errors              : {},
      disabled            : {},
      formAction          : this.props.formAction,
      formUrl             : this.props.formUrl,
      closeOnSuccess      : false,
      'task[name]'        : this.props.task.name || '',
      'task[why]'         : this.props.task.why || '',
      'task[description]' : this.props.task.description || '',
      'task[requirements]': this.props.task.requirements || '',
      'task[amount]'      : this.props.task.amount || '',
      'task[proof_link]'  : this.props.task.proofLink || ''
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
        <Layout
          className="task-form"
          title={this.state.formAction === 'POST' ? 'Create a New Task' : 'Edit Task'}
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
        >
          <Flash messages={this.state.flashMessages} />

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
        </Layout>
      </React.Fragment>
    )
  }
}

TaskForm.propTypes = {
  task        : PropTypes.object.isRequired,
  token       : PropTypes.object.isRequired,
  formUrl     : PropTypes.string.isRequired,
  formAction  : PropTypes.string.isRequired,
  urlOnSuccess: PropTypes.string.isRequired,
  csrfToken   : PropTypes.string.isRequired
}
TaskForm.defaultProps = {
  task        : {'default': '_'},
  token       : {'default': '_'},
  formUrl     : '/',
  formAction  : 'POST',
  urlOnSuccess: '/',
  csrfToken   : '00'
}
export default TaskForm
