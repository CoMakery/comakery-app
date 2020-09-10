import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldDropdownHalfed from './styleguide/InputFieldDropdownHalfed'
import InputFieldHalfed from './styleguide/InputFieldHalfed'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'

class TokenForm extends React.Component {
  constructor(props) {
    super(props)

    this.errorAdd = this.errorAdd.bind(this)
    this.errorRemove = this.errorRemove.bind(this)
    this.disable = this.disable.bind(this)
    this.enable = this.enable.bind(this)
    this.disableContractFields = this.disableContractFields.bind(this)
    this.enableContractFields = this.enableContractFields.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)
    this.fetchSymbolAndDecimals = this.fetchSymbolAndDecimals.bind(this)
    this.verifyImgRes = this.verifyImgRes.bind(this)

    this.lofoInputRef = React.createRef()

    this.state = {
      flashMessages                     : [],
      errors                            : {},
      disabled                          : {},
      formAction                        : this.props.formAction,
      formUrl                           : this.props.formUrl,
      closeOnSuccess                    : false,
      'token[_token_type]'                : this.props.token._tokenType || Object.values(this.props.tokenTypes)[0],
      'token[unlisted]'                 : this.props.token.unlisted ? 'true' : 'false',
      'token[name]'                     : this.props.token.name || '',
      'token[symbol]'                   : this.props.token.symbol || '',
      'token[contract_address]'         : this.props.token.contractAddress || '',
      'token[decimal_places]'           : (!this.props.token.decimalPlaces && this.props.token.decimalPlaces !== 0 ? '' : this.props.token.decimalPlaces.toString()),
      'token[_blockchain]'       : this.props.token._blockchain || Object.values(this.props.blockchains)[0]
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

  disableContractFields() {
    this.disable([
      'token[_token_type]',
      'token[_blockchain]',
      'token[contract_address]'
    ])
  }

  enableContractFields() {
    this.enable([
      'token[_token_type]',
      'token[_blockchain]',
      'token[contract_address]'
    ])
  }

  verifyImgRes(img) {
    if ((img.naturalWidth < 500) || (img.naturalHeight < 500) || (img.naturalWidth / img.naturalHeight !== 1)) {
      this.lofoInputRef.current.value = ''
      this.errorAdd('token[logo_image]', 'invalid resolution')
    } else {
      this.errorRemove('token[logo_image]')
    }
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

    switch (event.target.name) {
      case 'token[contract_address]':
        this.fetchSymbolAndDecimals(event.target.value, this.state['token[_blockchain]'])
        break

      case 'token[_blockchain]':
        this.fetchSymbolAndDecimals(this.state['token[contract_address]'], event.target.value)
        break

      case 'token[_token_type]':
        this.setState({
          'token[symbol]'                   : '',
          'token[decimal_places]'           : '',
          'token[contract_address]'         : ''
        })
        this.enableContractFields()
        break

      default:
        return
    }
  }

  fetchSymbolAndDecimals(address, network) {
    if (address === '' || network === '') {
      return
    }

    this.setState({
      'token[symbol]'        : '',
      'token[decimal_places]': ''
    })
    this.disableContractFields()

    fetchPolyfill('/tokens/fetch_contract_details', {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({'address': address, 'network': network, 'authenticity_token': this.props.csrfToken}),
      headers    : {
        'Accept'      : 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        return response.json()
      } else {
        this.setState(state => ({
          flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': response.text()}])
        }))
        this.enableContractFields()
        throw Error(response.text())
      }
    }).then(data => {
      let symbol = data.symbol
      let decimals = data.decimals
      if (symbol || decimals) {
        this.setState({
          'token[symbol]'        : symbol,
          'token[decimal_places]': decimals.toString()
        })
      }
      this.enableContractFields()
    })
  }

  handleSubmit(event) {
    event.preventDefault()

    this.disable(['token[submit]', 'token[submit_and_close]'])

    if (!event.target.checkValidity()) {
      this.enable(['token[submit]', 'token[submit_and_close]'])
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
          if (this.state.formAction === 'POST') {
            response.json().then(data => {
              this.setState(state => ({
                formAction   : 'PUT',
                formUrl      : `/tokens/${data.id}`,
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': 'Token Created'}])
              }))
              history.replaceState(
                {},
                document.title,
                `${window.location.origin}/tokens/${data.id}`
              )
            })
          } else {
            this.setState(state => ({
              flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': 'Token Updated'}])
            }))
          }
          this.enable(['token[submit]', 'token[submit_and_close]'])
        }
      } else {
        response.json().then(data => {
          this.setState(state => ({
            errors       : data.errors,
            flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': data.message}])
          }))
          this.enable(['token[submit]', 'token[submit_and_close]'])
        })
      }
    })
  }

  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
  }

  render() {
    return (
      <React.Fragment>
        <Layout
          className='token-form'
          title={this.state.formAction === 'POST' ? 'Create a New Token' : 'Edit Token'}
          hasBackButton
          subfooter={
            <React.Fragment>
              <Button
                value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
                type='submit'
                form='token-form--form'
                disabled={this.state.disabled['token[submit_and_close]']}
                onClick={() => this.setState({closeOnSuccess: true})}
              />
              <ButtonBorder
                value={this.state.formAction === 'POST' ? 'create' : 'save'}
                type='submit'
                form='token-form--form'
                disabled={this.state.disabled['token[submit]']}
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

          <form className='token-form--form' id='token-form--form' onSubmit={this.handleSubmit}>
            <InputFieldDropdownHalfed
              title='payment type'
              required
              name='token[_token_type]'
              value={this.state['token[_token_type]']}
              errorText={this.state.errors['token[_token_type]']}
              disabled={this.state.disabled['token[_token_type]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.tokenTypes)}
              symbolLimit={0}
            />

            <InputFieldDropdownHalfed
              title='visibility'
              required
              name='token[unlisted]'
              value={this.state['token[unlisted]']}
              errorText={this.state.errors['token[unlisted]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries({
                'Listed'  : 'false',
                'Unlisted': 'true'
              })}
            />

            {this.state['token[_token_type]'].match(/erc20|qrc20|comakery/) &&
              <InputFieldHalfed
                title='token name'
                required
                name='token[name]'
                value={this.state['token[name]']}
                errorText={this.state.errors['token[name]']}
                placeholder='Bitcoin'
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[_token_type]'].match(/erc20|comakery|qrc20/) &&
              <InputFieldHalfed
                title='contract address'
                required
                name='token[contract_address]'
                value={this.state['token[contract_address]']}
                errorText={this.state.errors['token[contract_address]']}
                readOnly={this.state.disabled['token[contract_address]']}
                placeholder='2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc'
                pattern='[a-fA-F0-9]{40}'
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[_token_type]'].match(/qrc20|erc20|comakery/) &&
              <InputFieldHalfed
                title='token symbol'
                required
                name='token[symbol]'
                value={this.state['token[symbol]']}
                errorText={this.state.errors['token[symbol]']}
                placeholder='...'
                readOnly
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[_token_type]'].match(/qrc20|erc20|comakery/) &&
              <InputFieldHalfed
                title='decimal places'
                required
                name='token[decimal_places]'
                value={this.state['token[decimal_places]']}
                errorText={this.state.errors['token[decimal_places]']}
                placeholder='...'
                pattern='\d{1-2}'
                readOnly
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[_token_type]'].match('qrc20|qtum|ada|btc|eos|xtz|dag|eth|erc20|comakery') &&
              <InputFieldDropdownHalfed
                title='blockchain network'
                required
                name='token[_blockchain]'
                value={this.state['token[_blockchain]']}
                errorText={this.state.errors['token[_blockchain]']}
                disabled={this.state.disabled['token[_blockchain]']}
                eventHandler={this.handleFieldChange}
                selectEntries={Object.entries(this.props.blockchains)}
              />
            }

            <InputFieldUploadFile
              title='token logo'
              required
              name='token[logo_image]'
              errorText={this.state.errors['token[logo_image]']}
              imgPreviewUrl={this.props.token.logoUrl}
              imgRequirements='Image should be at least 500px x 500px'
              imgVerifier={this.verifyImgRes}
              imgInputRef={this.lofoInputRef}
            />

            <input
              type='hidden'
              name='authenticity_token'
              value={this.props.csrfToken}
              readOnly
            />
          </form>
        </Layout>
      </React.Fragment>
    )
  }
}

TokenForm.propTypes = {
  token             : PropTypes.object.isRequired,
  tokenTypes         : PropTypes.object.isRequired,
  blockchains: PropTypes.object.isRequired,
  formUrl           : PropTypes.string.isRequired,
  formAction        : PropTypes.string.isRequired,
  urlOnSuccess      : PropTypes.string.isRequired,
  csrfToken         : PropTypes.string.isRequired
}
TokenForm.defaultProps = {
  token             : {'default': '_'},
  tokenTypes         : {'default': '_'},
  blockchains: {'default': '_'},
  formUrl           : '/',
  formAction        : 'POST',
  urlOnSuccess      : '/',
  csrfToken         : '00'
}
export default TokenForm
