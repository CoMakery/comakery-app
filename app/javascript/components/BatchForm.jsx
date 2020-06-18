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

class BatchForm extends React.Component {
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
      'batch[state]'      : this.props.batch.state,
      'batch[name]'       : this.props.batch.name || '',
      'batch[goal]'       : this.props.batch.goal || '',
      'batch[description]': this.props.batch.description || ''
    }
  }

  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
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
    a.forEach(n => (d = Object.assign({}, d, {[n]: true})))
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

    this.disable(['batch[submit]', 'batch[submit_and_close]'])

    if (!event.target.checkValidity()) {
      this.enable(['batch[submit]', 'batch[submit_and_close]'])
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
                formUrl      : `/projects/${this.props.projectId}/batches/${data.id}`,
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': data.message}])
              }))
              history.replaceState(
                {},
                document.title,
                `${window.location.origin}/projects/${this.props.projectId}/batches/${data.id}/edit`
              )
            } else {
              this.setState(state => ({
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': data.message}])
              }))
            }
          })
          this.enable(['batch[submit]', 'batch[submit_and_close]'])
        }
      } else {
        response.json().then(data => {
          this.setState(state => ({
            errors       : data.errors,
            flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': data.message}])
          }))
          this.enable(['batch[submit]', 'batch[submit_and_close]'])
        })
      }
    })
  }

  render() {
    return (
      <React.Fragment>
        <ProjectSetup
          className='batch-form'
          projectForHeader={this.props.projectForHeader}
          missionForHeader={this.props.missionForHeader}
          owner
          current='batches'
          sidebar={
            <React.Fragment>
              <div className='batch-index--sidebar'>
                <SidebarItem
                  className='batch-index--sidebar--item batch-index--sidebar--item__form'
                  text={this.state['batch[name]'] || 'New Batch'}
                  selected
                />
                <hr className='batch-index--sidebar--hr' />
              </div>
            </React.Fragment>
          }
          hasBackButton
          subfooter={
            <React.Fragment>
              <Button
                value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
                type='submit'
                form='batch-form--form'
                disabled={this.state.disabled['batch[submit_and_close]']}
                onClick={() => this.setState({closeOnSuccess: true})}
              />
              <ButtonBorder
                value={this.state.formAction === 'POST' ? 'create' : 'save'}
                type='submit'
                form='batch-form--form'
                disabled={this.state.disabled['batch[submit]']}
                onClick={() => this.setState({closeOnSuccess: false})}
              />
              <ButtonBorder
                value='cancel'
                onClick={this.goBack}
              />
            </React.Fragment>
          }
        >
          <Flash messages={this.state.flashMessages} />

          <div className='batch-form--form--title'>
            {this.state.formAction === 'POST' ? 'Create a New Batch' : 'Edit Batch'}
          </div>

          <form className='batch-form--form' id='batch-form--form' onSubmit={this.handleSubmit}>
            <InputFieldDropdown
              title='State'
              required
              name='batch[state]'
              value={this.state['batch[state]']}
              errorText={this.state.errors['batch[state]']}
              disabled={this.state.disabled['batch[state]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.states)}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title='name'
              required
              name='batch[name]'
              value={this.state['batch[name]']}
              errorText={this.state.errors['batch[name]']}
              eventHandler={this.handleFieldChange}
              placeholder='Provide a clear title for the batch'
              symbolLimit={100}
            />

            <InputFieldDescriptionMiddle
              title='the goal of the batch'
              name='batch[goal]'
              value={this.state['batch[goal]']}
              errorText={this.state.errors['batch[goal]']}
              eventHandler={this.handleFieldChange}
              placeholder='Let people know what will be the result of this batch being completed (ex: When this batch is finished, the xxxx will now do yyyy)'
              symbolLimit={250}
            />

            <InputFieldDescription
              title='description'
              name='batch[description]'
              value={this.state['batch[description]']}
              errorText={this.state.errors['batch[description]']}
              eventHandler={this.handleFieldChange}
              placeholder='Provide a longer description about the batch focus, the type of work involved, and how it will relate to the larger project'
              symbolLimit={750}
            />

            <InputFieldUploadFile
              title='diagram or screenshot'
              name='batch[diagram]'
              errorText={this.state.errors['batch[diagram]']}
              imgPreviewUrl={this.props.batch.diagramUrl}
              imgPreviewDimensions='100x100'
            />

            <input
              type='hidden'
              name='authenticity_token'
              value={this.props.csrfToken}
              readOnly
            />
          </form>
        </ProjectSetup>
      </React.Fragment>
    )
  }
}

BatchForm.propTypes = {
  batch           : PropTypes.object.isRequired,
  states          : PropTypes.object.isRequired,
  project         : PropTypes.object.isRequired,
  formUrl         : PropTypes.string.isRequired,
  formAction      : PropTypes.string.isRequired,
  urlOnSuccess    : PropTypes.string.isRequired,
  projectId       : PropTypes.number.isRequired,
  csrfToken       : PropTypes.string.isRequired,
  missionForHeader: PropTypes.object,
  projectForHeader: PropTypes.object
}
BatchForm.defaultProps = {
  batch           : {'default': '_'},
  states          : {'default': '_'},
  project         : {'default': '_'},
  formUrl         : '/',
  formAction      : 'POST',
  urlOnSuccess    : '/',
  projectId       : 0,
  csrfToken       : '00',
  missionForHeader: null,
  projectForHeader: null
}
export default BatchForm
