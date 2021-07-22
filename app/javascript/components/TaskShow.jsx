import React from 'react'
import PropTypes from 'prop-types'
import ProjectSetup from './layouts/ProjectSetup'
import { fetch as fetchPolyfill } from 'whatwg-fetch'
import { toSnakeCase } from './utils'
import { Decimal } from 'decimal.js'
import InputFieldDropdown from './styleguide/InputFieldDropdown'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescriptionMiddle from './styleguide/InputFieldDescriptionMiddle'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'
import SidebarItem from './styleguide/SidebarItem'

class TaskShow extends React.Component {
  constructor(props) {
    super(props)

    this.goBack = this.goBack.bind(this)
    this.errorAdd = this.errorAdd.bind(this)
    this.errorRemove = this.errorRemove.bind(this)
    this.disable = this.disable.bind(this)
    this.enable = this.enable.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)
    this.fetchRecipientAddress = this.fetchRecipientAddress.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)

    this.state = {
      flashMessages     : [],
      errors            : {},
      disabled          : {},
      formAction        : this.props.formAction,
      formUrl           : this.props.formUrl,
      closeOnSuccess    : false,
      detailsFetched    : false,
      'task[channel_id]': Object.values(this.props.channels)[0],
      'task[quantity]'  : this.props.task.quantity
    }
  }

  goBack() {
    if (this.state.detailsFetched) {
      this.setState({
        detailsFetched: false
      })
    } else {
      typeof window === 'undefined' ? null : window.history.back()
    }
  }

  errorAdd(key, e) {
    let errors = this.state.errors

    if (errors.hasOwnProperty(key)) {
      if (errors[key].includes(e)) {
        return
      }

      this.setState({
        errors: Object.assign({}, errors, {[key]: [...errors[key], e]})
      })
    } else {
      this.setState({
        errors: Object.assign({}, errors, {[key]: Object.assign([], errors[key], [e])})
      })
    }
  }

  errorRemove(key, e) {
    let errors = this.state.errors

    if (errors[key] === undefined) {
      return
    }

    let index = errors[key].indexOf(e)

    errors[key].splice(index, 1)

    if (errors[key].length === 0) {
      delete errors[key]
    }

    this.setState({
      errors: errors
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

  fetchRecipientAddress(channelId, uid, email) {
    this.setState({
      'task[recipient_address]': ''
    })

    fetchPolyfill(this.props.recipientAddressUrl, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        'channel_id'        : channelId,
        'uid'               : uid,
        'email'             : email,
        'authenticity_token': this.props.csrfToken
      }),
      headers: {
        'Accept'      : 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        return response.json()
      } else {
        let errors = response.text()
        this.setState(state => ({
          flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': errors}])
        }))
        throw Error(errors)
      }
    }).then(data => {
      this.setState({
        'task[recipient_address]'    : data.address,
        'task[recipient_address_url]': data.walletUrl
      })
    })
  }

  handleFieldChange(event) {
    const errorMessage = 'invalid value'
    this.setState({ [event.target.name]: event.target.value })

    if (!event.target.checkValidity()) {
      this.errorAdd(event.target.name, errorMessage)
      return
    } else {
      this.errorRemove(event.target.name, errorMessage)
    }

    if (event.target.value === '') {
      return
    }
  }

  handleSubmit(event) {
    event.preventDefault()

    this.disable(['task[submit]'])

    if (!event.target.checkValidity()) {
      this.enable(['task[submit]'])
      return
    }

    if (!this.state.detailsFetched) {
      this.fetchRecipientAddress(
        this.state['task[channel_id]'],
        this.state['task[uid]'] || (this.state['task[channel_id]'] !== '' ? Object.values(this.props.members[this.state['task[channel_id]']])[0] : null),
        this.state['task[email]']
      )

      this.setState({
        detailsFetched: true
      })

      this.enable(['task[submit]'])
      return
    }

    const formData = new FormData(event.target)
    if (this.state['task[channel_id]'] !== '') {
      formData.append('task[channel_id]', this.state['task[channel_id]'] || Object.values(this.props.channels[0]))
      formData.append('task[uid]', this.state['task[uid]'] || Object.values(this.props.members[this.state['task[channel_id]']])[0])
    }

    fetchPolyfill(this.state.formUrl, {
      credentials: 'same-origin',
      method     : this.state.formAction,
      body       : formData,
      headers    : {
        'X-Key-Inflection': 'snake'
      }
    }).then(response => {
      if (response.status === 200) {
        window.location = this.props.urlOnSuccess
      } else {
        response.json().then(data => {
          this.setState(state => ({
            detailsFetched: false,
            errors        : Object.entries(data.errors).reduce((obj, [k, v]) => ({ ...obj, [toSnakeCase(k)]: [v] }), {}),
            flashMessages : state.flashMessages.concat([{'severity': 'error', 'text': data.message}])
          }))
          this.enable(['task[submit]'])
        })
      }
    })
  }

  render() {
    return (
      <React.Fragment>
        <ProjectSetup
          className='task-award-form'
          projectForHeader={this.props.projectForHeader}
          missionForHeader={this.props.missionForHeader}
          owner
          current='batches'
          hasBackButton
          subfooter={
            <React.Fragment>
              <Button
                className='metamask-transfer-btn'
                value={this.state.detailsFetched ? 'issue award' : 'proceed'}
                type='submit'
                form='task-award-form--form'
                disabled={this.state.disabled['task[submit]']}
              />
              <ButtonBorder
                value={this.state.detailsFetched ? 'edit' : 'cancel'}
                onClick={this.goBack}
              />
            </React.Fragment>
          }
          sidebar={
            <React.Fragment>
              <div className='batch-index--sidebar'>
                <SidebarItem
                  className='batch-index--sidebar--item batch-index--sidebar--item__form'
                  text={this.props.batch.name}
                  selected
                />
                <hr className='batch-index--sidebar--hr' />
              </div>
            </React.Fragment>
          }
        >
          <Flash messages={this.state.flashMessages} />

          <div className='task-form--form--title'>
            {`Issue Award For Task: ${this.props.task.name}`}
          </div>

          <form className='task-award-form--form' id='task-award-form--form' onSubmit={this.handleSubmit}>
            <InputFieldDropdown
              title='communication channel'
              name='task[channel_id]'
              value={this.state['task[channel_id]']}
              errors={this.state.errors['task[channel_id]']}
              disabled={this.state.detailsFetched || this.state.disabled['task[channel_id]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.channels)}
              symbolLimit={0}
            />

            {this.state['task[channel_id]'] !== '' &&
              <InputFieldDropdown
                title='username'
                name='task[uid]'
                value={this.state['task[uid]'] || Object.values(this.props.members[this.state['task[channel_id]']])[0]}
                errors={this.state.errors['task[uid]']}
                disabled={this.state.detailsFetched || this.state.disabled['task[uid]']}
                eventHandler={this.handleFieldChange}
                selectEntries={Object.entries(this.props.members[this.state['task[channel_id]']])}
                symbolLimit={0}
              />
            }

            {this.state['task[channel_id]'] === '' &&
              <InputFieldWhiteDark
                title='email'
                type='email'
                required
                name='task[email]'
                value={this.state['task[email]']}
                errors={this.state.errors['task[email]']}
                readOnly={this.state.detailsFetched || this.state.disabled['task[email]']}
                eventHandler={this.handleFieldChange}
                placeholder='Enter the recepient email address'
                symbolLimit={0}
              />
            }

            <InputFieldDescriptionMiddle
              title='message'
              recommended
              name='task[message]'
              value={this.state['task[message]']}
              errors={this.state.errors['task[message]']}
              eventHandler={this.handleFieldChange}
              readOnly={this.state.detailsFetched || this.state.disabled['task[message]']}
              placeholder='Give a shoutout or offer some tips to the person who completed the task'
              symbolLimit={150}
            />

            <InputFieldWhiteDark
              title='quantity'
              required
              name='task[quantity]'
              value={this.state['task[quantity]']}
              errors={this.state.errors['task[quantity]']}
              eventHandler={this.handleFieldChange}
              type='number'
              min='0'
              step='0.01'
              readOnly={this.state.detailsFetched || this.state.disabled['task[quantity]']}
              placeholder='The # of awards to send'
              symbolLimit={0}
            />

            <div className='task-award-form--form--field'>
              <div className='task-award-form--form--field--title'>
                {`total award amount (${this.props.token.symbol ? this.props.token.symbol : 'POINTS - TOKEN NOT SPECIFIED'})`}
              </div>
              <div className='task-award-form--form--field--value'>
                {
                  Decimal(
                    this.props.task.amount || this.props.batch.amount || 0
                  ).toFixed(
                    this.props.token.decimalPlaces || 0,
                    Decimal.ROUND_DOWN
                  )
                }
                {' × '}
                {parseFloat(this.state['task[quantity]'])}
                {' = '}
                {
                  Decimal.mul(
                    this.props.task.amount || this.props.batch.amount || 0,
                    parseFloat(this.state['task[quantity]'])
                  ).toDecimalPlaces(
                    this.props.token.decimalPlaces || 0,
                    Decimal.ROUND_DOWN
                  ).toFixed(
                    this.props.token.decimalPlaces || 0,
                    Decimal.ROUND_DOWN
                  )
                }
              </div>
            </div>

            {this.state.detailsFetched &&
              <div className='task-award-form--form--field'>
                <div className='task-award-form--form--field--title'>
                  recipient address
                </div>
                <div className='task-award-form--form--field--value'>
                  {!this.state['task[recipient_address]'] &&
                    <span>
                      The recipient must register their address before they can accept the award.
                    </span>
                  }
                  {this.state['task[recipient_address]'] &&
                    <a href={this.state['task[recipient_address_url]']} target='_blank'>
                      {this.state['task[recipient_address]']}
                    </a>
                  }
                </div>
              </div>
            }

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
TaskShow.propTypes = {
  task               : PropTypes.object.isRequired,
  batch              : PropTypes.object.isRequired,
  project            : PropTypes.object.isRequired,
  token              : PropTypes.object.isRequired,
  channels           : PropTypes.object.isRequired,
  members            : PropTypes.object.isRequired,
  recipientAddressUrl: PropTypes.string.isRequired,
  formUrl            : PropTypes.string.isRequired,
  formAction         : PropTypes.string.isRequired,
  urlOnSuccess       : PropTypes.string.isRequired,
  csrfToken          : PropTypes.string.isRequired,
  missionForHeader   : PropTypes.object,
  projectForHeader   : PropTypes.object
}
TaskShow.defaultProps = {
  task: {
    'id'         : 28,
    'awardTypeId': 10,
    'name'       : 'Task name',
    'amount'     : '100.0',
    'quantity'   : 1
  },
  batch  : {'default': '_'},
  project: {'default': '_'},
  token  : {
    'symbol'       : 'DMT',
    'decimalPlaces': 8
  },
  channels           : {'email': '', 'default': '1'},
  members            : {'1': {'default': '_'}},
  recipientAddressUrl: '/',
  formUrl            : '/',
  formAction         : 'POST',
  urlOnSuccess       : '/',
  csrfToken          : '00',
  missionForHeader   : null,
  projectForHeader   : null
}
export default TaskShow
