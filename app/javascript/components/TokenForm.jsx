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
      'token[coin_type]'                : this.props.token.coinType || Object.values(this.props.coinTypes)[0],
      'token[unlisted]'                 : this.props.token.unlisted ? 'true' : 'false',
      'token[name]'                     : this.props.token.name || '',
      'token[symbol]'                   : this.props.token.symbol || '',
      'token[contract_address]'         : this.props.token.contractAddress || '',
      'token[ethereum_contract_address]': this.props.token.ethereumContractAddress || '',
      'token[decimal_places]'           : (!this.props.token.decimalPlaces && this.props.token.decimalPlaces !== 0 ? '' : this.props.token.decimalPlaces.toString()),
      'token[blockchain_network]'       : this.props.token.blockchainNetwork || Object.values(this.props.blockchainNetworks)[0],
      'token[ethereum_network]'         : this.props.token.ethereumNetwork || Object.values(this.props.ethereumNetworks)[0]
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

  disableContractFields() {
    this.disable([
      'token[coin_type]',
      'token[blockchain_network]',
      'token[ethereum_network]',
      'token[contract_address]',
      'token[ethereum_contract_address]'
    ])
  }

  enableContractFields() {
    this.enable([
      'token[coin_type]',
      'token[blockchain_network]',
      'token[ethereum_network]',
      'token[contract_address]',
      'token[ethereum_contract_address]'
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
        this.fetchSymbolAndDecimals(event.target.value, this.state['token[blockchain_network]'])
        break

      case 'token[blockchain_network]':
        this.fetchSymbolAndDecimals(this.state['token[contract_address]'], event.target.value)
        break

      case 'token[ethereum_contract_address]':
        this.fetchSymbolAndDecimals(event.target.value, this.state['token[ethereum_network]'])
        break

      case 'token[ethereum_network]':
        this.fetchSymbolAndDecimals(this.state['token[ethereum_contract_address]'], event.target.value)
        break

      case 'token[coin_type]':
        this.setState({
          'token[symbol]'                   : '',
          'token[decimal_places]'           : '',
          'token[contract_address]'         : '',
          'token[ethereum_contract_address]': ''
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
    typeof window === 'undefined' ? null : window.location = '/tokens'
  }

  render() {
    return (
      <React.Fragment>
        <Layout
          className="token-form"
          title={this.state.formAction === 'POST' ? 'Create a New Token' : 'Edit Token'}
          hasBackButton
          subfooter={
            <React.Fragment>
              <Button
                value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
                type="submit"
                form="token-form--form"
                disabled={this.state.disabled['token[submit_and_close]']}
                onClick={() => this.setState({closeOnSuccess: true})}
              />
              <ButtonBorder
                value={this.state.formAction === 'POST' ? 'create' : 'save'}
                type="submit"
                form="token-form--form"
                disabled={this.state.disabled['token[submit]']}
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

          <form className="token-form--form" id="token-form--form" onSubmit={this.handleSubmit}>
            <InputFieldDropdownHalfed
              title="payment type"
              required
              name="token[coin_type]"
              value={this.state['token[coin_type]']}
              errorText={this.state.errors['token[coin_type]']}
              disabled={this.state.disabled['token[coin_type]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.coinTypes)}
              symbolLimit={0}
            />

            <InputFieldDropdownHalfed
              title="visibility"
              required
              name="token[unlisted]"
              value={this.state['token[unlisted]']}
              errorText={this.state.errors['token[unlisted]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries({
                'Listed'  : 'false',
                'Unlisted': 'true'
              })}
            />

            {this.state['token[coin_type]'].match(/erc20|qrc20|comakery/) &&
              <InputFieldHalfed
                title="token name"
                required
                name="token[name]"
                value={this.state['token[name]']}
                errorText={this.state.errors['token[name]']}
                placeholder="Bitcoin"
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[coin_type]'] === 'qrc20' &&
              <InputFieldHalfed
                title="contract address"
                required
                name="token[contract_address]"
                value={this.state['token[contract_address]']}
                errorText={this.state.errors['token[contract_address]']}
                readOnly={this.state.disabled['token[contract_address]']}
                placeholder="2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc"
                pattern="[a-fA-F0-9]{40}"
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[coin_type]'].match(/erc20|comakery/) &&
              <InputFieldHalfed
                title="contract address"
                required
                name="token[ethereum_contract_address]"
                value={this.state['token[ethereum_contract_address]']}
                errorText={this.state.errors['token[ethereum_contract_address]']}
                readOnly={this.state.disabled['token[ethereum_contract_address]']}
                placeholder="0x6c6ee5e31d828de241282b9606c8e98ea48526e2"
                pattern="0x[a-fA-F0-9]{40}"
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[coin_type]'].match(/qrc20|erc20|comakery/) &&
              <InputFieldHalfed
                title="token symbol"
                required
                name="token[symbol]"
                value={this.state['token[symbol]']}
                errorText={this.state.errors['token[symbol]']}
                placeholder="..."
                readOnly
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[coin_type]'].match(/qrc20|erc20|comakery/) &&
              <InputFieldHalfed
                title="decimal places"
                required
                name="token[decimal_places]"
                value={this.state['token[decimal_places]']}
                errorText={this.state.errors['token[decimal_places]']}
                placeholder="..."
                pattern="\d{1-2}"
                readOnly
                eventHandler={this.handleFieldChange}
                symbolLimit={0}
              />
            }

            {this.state['token[coin_type]'].match('qrc20|qtum|ada|btc|eos|xtz') &&
              <InputFieldDropdownHalfed
                title="blockchain network"
                required
                name="token[blockchain_network]"
                value={this.state['token[blockchain_network]']}
                errorText={this.state.errors['token[blockchain_network]']}
                disabled={this.state.disabled['token[blockchain_network]']}
                eventHandler={this.handleFieldChange}
                selectEntries={Object.entries(this.props.blockchainNetworks)}
              />
            }

            {this.state['token[coin_type]'].match(/eth|erc20|comakery/) &&
              <InputFieldDropdownHalfed
                title="blockchain network"
                required
                name="token[ethereum_network]"
                value={this.state['token[ethereum_network]']}
                errorText={this.state.errors['token[ethereum_network]']}
                disabled={this.state.disabled['token[ethereum_network]']}
                eventHandler={this.handleFieldChange}
                selectEntries={Object.entries(this.props.ethereumNetworks)}
              />
            }

            <InputFieldUploadFile
              title="token logo"
              required
              name="token[logo_image]"
              errorText={this.state.errors['token[logo_image]']}
              imgPreviewUrl={this.props.token.logoUrl}
              imgRequirements="Image should be at least 500px x 500px"
              imgVerifier={this.verifyImgRes}
              imgInputRef={this.lofoInputRef}
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

TokenForm.propTypes = {
  token             : PropTypes.object.isRequired,
  coinTypes         : PropTypes.object.isRequired,
  ethereumNetworks  : PropTypes.object.isRequired,
  blockchainNetworks: PropTypes.object.isRequired,
  formUrl           : PropTypes.string.isRequired,
  formAction        : PropTypes.string.isRequired,
  urlOnSuccess      : PropTypes.string.isRequired,
  csrfToken         : PropTypes.string.isRequired
}
TokenForm.defaultProps = {
  token             : {'default': '_'},
  coinTypes         : {'default': '_'},
  ethereumNetworks  : {'default': '_'},
  blockchainNetworks: {'default': '_'},
  formUrl           : '/',
  formAction        : 'POST',
  urlOnSuccess      : '/',
  csrfToken         : '00'
}
export default TokenForm
