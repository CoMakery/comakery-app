import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldDropdown from './styleguide/InputFieldDropdown'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescription from './styleguide/InputFieldDescription'
import InputFieldDescriptionMiddle from './styleguide/InputFieldDescriptionMiddle'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'

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
            disabled                          : {},
      formAction          : this.props.formAction,
      formUrl             : this.props.formUrl,
      closeOnSuccess      : false,
      'batch[specialty]'  : this.props.batch.specialty || Object.values(this.props.specialties)[0],
      'batch[name]'       : this.props.batch.name || '',
      'batch[goal]'       : this.props.batch.goal || '',
      'batch[description]': this.props.batch.description || ''
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
                formUrl      : `/projects/${this.props.projectId}/award_types/${data.id}`,
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': data.message}])
              }))
              history.replaceState(
                {},
                document.title,
                `${window.location.origin}/projects/${this.props.projectId}/award_types/${data.id}/edit`
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
        <Layout
          className="batch-form"
          title={this.state.formAction === 'POST' ? 'Create a New Batch' : 'Edit Batch'}
          hasBackButton
          subfooter={
            <React.Fragment>
              <Button
                value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
                type="submit"
                form="batch-form--form"
                disabled={this.state.disabled['batch[submit_and_close]']}
                onClick={() => this.setState({closeOnSuccess: true})}
              />
              <ButtonBorder
                value={this.state.formAction === 'POST' ? 'create' : 'save'}
                type="submit"
                form="batch-form--form"
                disabled={this.state.disabled['batch[submit]']}
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

          <form className="batch-form--form" id="batch-form--form" onSubmit={this.handleSubmit}>
            <InputFieldDropdown
              title="specialty"
              required
              name="batch[specialty]"
              value={this.state['batch[specialty]']}
              errorText={this.state.errors['batch[specialty]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.specialties)}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="name"
              required
              name="batch[name]"
              value={this.state['batch[name]']}
              errorText={this.state.errors['batch[name]']}
              eventHandler={this.handleFieldChange}
              symbolLimit={100}
            />

            <InputFieldDescriptionMiddle
              title="the goal of the batch"
              required
              name="batch[goal]"
              value={this.state['batch[goal]']}
              errorText={this.state.errors['batch[goal]']}
              eventHandler={this.handleFieldChange}
              symbolLimit={250}
            />

            <InputFieldDescription
              title="description"
              required
              name="batch[description]"
              value={this.state['batch[description]']}
              errorText={this.state.errors['batch[description]']}
              eventHandler={this.handleFieldChange}
              symbolLimit={750}
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

BatchForm.propTypes = {
  batch       : PropTypes.object.isRequired,
  specialties : PropTypes.object.isRequired,
  formUrl     : PropTypes.string.isRequired,
  formAction  : PropTypes.string.isRequired,
  urlOnSuccess: PropTypes.string.isRequired,
  projectId   : PropTypes.number.isRequired,
  csrfToken   : PropTypes.string.isRequired
}
BatchForm.defaultProps = {
  token       : {'default': '_'},
  specialties : {'default': '_'},
  formUrl     : '/',
  formAction  : 'POST',
  urlOnSuccess: '/',
  projectId   : null,
  csrfToken   : '00'
}
export default BatchForm
