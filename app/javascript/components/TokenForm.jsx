import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'

class TokenForm extends React.Component {
  constructor(props) {
    super(props)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)
    this.handleLogoChange = this.handleLogoChange.bind(this)
    this.noEmptyFields = this.noEmptyFields.bind(this)
    this.fetchSymbolAndDecimals = this.fetchSymbolAndDecimals.bind(this)
    this.state = {
      contractAddressEditable           : true,
      ethereumContractAddressEditable   : true,
      paymentTypeChoosable              : true,
      blockchainNetworkChoosable        : true,
      ethereumNetworkChoosable          : true,
      submitClickable                   : true,
      logoLocalUrl                      : null,
      displayValidationErrors           : false,
      serverErrors                      : {},
      'token[coin_type]'                : this.props.token.coinType || Object.values(this.props.coinTypes)[0],
      'token[name]'                     : this.props.token.name || '',
      'token[symbol]'                   : this.props.token.symbol || '',
      'token[contract_address]'         : this.props.token.contractAddress || '',
      'token[ethereum_contract_address]': this.props.token.ethereumContractAddress || '',
      'token[decimal_places]'           : (!this.props.token.decimalPlaces && this.props.token.decimalPlaces !== 0 ? '' : this.props.token.decimalPlaces),
      'token[blockchain_network]'       : this.props.token.blockchainNetwork || Object.values(this.props.blockchainNetworks)[0],
      'token[ethereum_network]'         : this.props.token.ethereumNetwork || Object.values(this.props.ethereumNetworks)[0]
    }
  }

  componentDidUpdate() {
    console.log(this.state)
  }

  noEmptyFields(formData) {
    if (!this.props.token.logoUrl && !this.state.logoLocalUrl) {
      return false
    }

    for (let v of formData.values()) {
      if (v == null) {
        return false
      }
    }

    return true
  }

  handleFieldChange(event) {
    this.setState({ [event.target.name]: event.target.value })

    if (!event.target.checkValidity()) {
      return
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
          'token[ethereum_contract_address]': '',
          contractAddressEditable           : true,
          ethereumContractAddressEditable   : true
        })
        break

      default:
        return
    }
  }

  handleLogoChange(event) {
    if (this.state.logoLocalUrl != null) {
      URL.revokeObjectURL(this.state.logoLocalUrl)
    }
    this.setState({
      logoLocalUrl: URL.createObjectURL(event.target.files[0])
    })
  }

  fetchSymbolAndDecimals(address, network) {
    if (address === '' || network === '') {
      return
    }

    this.setState({
      'token[symbol]'                : '',
      'token[decimal_places]'        : '',
      paymentTypeChoosable           : false,
      blockchainNetworkChoosable     : false,
      ethereumNetworkChoosable       : false,
      contractAddressEditable        : false,
      ethereumContractAddressEditable: false
    })

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
        console.log(response)
        return response.json()
      } else {
        this.setState({
          paymentTypeChoosable           : true,
          blockchainNetworkChoosable     : true,
          ethereumNetworkChoosable       : true,
          contractAddressEditable        : true,
          ethereumContractAddressEditable: true
        })
        throw Error(response.text())
      }
    }).then(data => {
      console.log(data)
      let symbol = data.symbol
      let decimals = data.decimals
      if (symbol == null || decimals == null) {
        this.setState({
          paymentTypeChoosable           : true,
          blockchainNetworkChoosable     : true,
          ethereumNetworkChoosable       : true,
          contractAddressEditable        : true,
          ethereumContractAddressEditable: true
        })
      } else {
        this.setState({
          'token[symbol]'                : symbol,
          'token[decimal_places]'        : decimals,
          paymentTypeChoosable           : true,
          blockchainNetworkChoosable     : true,
          ethereumNetworkChoosable       : true,
          contractAddressEditable        : true,
          ethereumContractAddressEditable: true
        })
      }
    })
  }

  handleSubmit(event) {
    event.preventDefault()

    this.setState({
      submitClickable: false
    })

    const formData = new FormData(event.target)

    if (event.target.checkValidity() && this.noEmptyFields(formData)) {
      this.setState({
        displayValidationErrors: false
      })
    } else {
      this.setState({
        displayValidationErrors: true,
        submitClickable        : true
      })
      return
    }

    fetchPolyfill(this.props.formUrl, {
      credentials: 'same-origin',
      method     : this.props.formAction,
      body       : formData,
      headers    : {
        'X-Key-Inflection': 'snake'
      }
    }).then(response => {
      if (response.status === 200) {
        window.location = this.props.urlOnSuccess
      } else {
        response.json().then(data => {
          this.setState({
            serverErrors   : data.errors,
            submitClickable: true
          })
        })
      }
    })
  }

  render() {
    return (
      <React.Fragment>
        <form onSubmit={this.handleSubmit} noValidate className={this.state.displayValidationErrors ? 'displayValidationErrors' : ''}>
          <label>
            payment type
            {this.state.serverErrors['token[coin_type]'] &&
              <span>
                {this.state.serverErrors['token[coin_type]']}
              </span>
            }
            <select
              required
              name="token[coin_type]"
              value={this.state['token[coin_type]']}
              onChange={this.handleFieldChange}
              disabled={!this.state.paymentTypeChoosable}
            >
              {Object.entries(this.props.coinTypes).map(([k, v]) =>
                <option key={v} value={v}>{k}</option>
              )}
            </select>
          </label>

          <label>
            token name
            {this.state.serverErrors['token[name]'] &&
              <span>
                {this.state.serverErrors['token[name]']}
              </span>
            }
            <input
              required
              type="text"
              name="token[name]"
              value={this.state['token[name]']}
              onChange={this.handleFieldChange}
              placeholder="Bitcoin"
            />
          </label>

          {this.state['token[coin_type]'].match(/qrc20|erc20/) &&
            <label>
              token symbol
              {this.state.serverErrors['token[symbol]'] &&
                <span>
                  {this.state.serverErrors['token[symbol]']}
                </span>
              }
              <input
                required
                type="text"
                name="token[symbol]"
                value={this.state['token[symbol]']}
                onChange={this.handleFieldChange}
                placeholder="..."
                readOnly
              />
            </label>
          }

          {this.state['token[coin_type]'].match(/qrc20|erc20/) &&
            <label>
              decimal places
              {this.state.serverErrors['token[decimal_places]'] &&
                <span>
                  {this.state.serverErrors['token[decimal_places]']}
                </span>
              }
              <input
                required
                type="text"
                name="token[decimal_places]"
                value={this.state['token[decimal_places]']}
                onChange={this.handleFieldChange}
                pattern="\d{1-2}"
                placeholder="..."
                readOnly
              />
            </label>
          }

          {this.state['token[coin_type]'] === 'qrc20' &&
            <label>
              contract address
              {this.state.serverErrors['token[contract_address]'] &&
                <span>
                  {this.state.serverErrors['token[contract_address]']}
                </span>
              }
              <input
                required
                type="text"
                name="token[contract_address]"
                value={this.state['token[contract_address]']}
                onChange={this.handleFieldChange}
                pattern="[a-fA-F0-9]{40}"
                placeholder="2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc"
                readOnly={!this.state.contractAddressEditable}
              />
            </label>
          }

          {this.state['token[coin_type]'] === 'erc20' &&
            <label>
              contract address
              {this.state.serverErrors['token[ethereum_contract_address]'] &&
                <span>
                  {this.state.serverErrors['token[ethereum_contract_address]']}
                </span>
              }
              <input
                required
                type="text"
                name="token[ethereum_contract_address]"
                value={this.state['token[ethereum_contract_address]']}
                onChange={this.handleFieldChange}
                pattern="0x[a-fA-F0-9]{40}"
                placeholder="0x6c6ee5e31d828de241282b9606c8e98ea48526e2"
                readOnly={!this.state.ethereumContractAddressEditable}
              />
            </label>
          }

          {this.state['token[coin_type]'] === 'qrc20' &&
            <label>
              blockchain network
              {this.state.serverErrors['token[blockchain_network]'] &&
                <span>
                  {this.state.serverErrors['token[blockchain_network]']}
                </span>
              }
              <select
                required
                name="token[blockchain_network]"
                value={this.state['token[blockchain_network]']}
                onChange={this.handleFieldChange}
                disabled={!this.state.blockchainNetworkChoosable}
              >
                {Object.entries(this.props.blockchainNetworks).map(([k, v]) =>
                  <option key={v} value={v}>{k}</option>
                )}
              </select>
            </label>
          }

          {this.state['token[coin_type]'].match(/eth|erc20/) &&
            <label>
              blockchain network
              {this.state.serverErrors['token[ethereum_network]'] &&
                <span>
                  {this.state.serverErrors['token[ethereum_network]']}
                </span>
              }
              <select
                required
                name="token[ethereum_network]"
                value={this.state['token[ethereum_network]']}
                onChange={this.handleFieldChange}
                disabled={!this.state.ethereumNetworkChoosable}
              >
                {Object.entries(this.props.ethereumNetworks).map(([k, v]) =>
                  <option key={v} value={v}>{k}</option>
                )}
              </select>
            </label>
          }

          <label>
            token logo
            {this.state.serverErrors['token[logo_image]'] &&
              <span>
                {this.state.serverErrors['token[logo_image]']}
              </span>
            }
            <input
              type="file"
              name="token[logo_image]"
              onChange={this.handleLogoChange}
            />
            {!this.state.logoLocalUrl &&
              <img
                src={this.props.token.logoUrl}
              />
            }
            {this.state.logoLocalUrl &&
              <img
                src={this.state.logoLocalUrl}
              />
            }
          </label>

          <input
            type="hidden"
            name="authenticity_token"
            value={this.props.csrfToken}
            readOnly
          />

          <input
            type="submit"
            value="save"
            disabled={!this.state.submitClickable}
          />
        </form>
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
  token             : {},
  coinTypes         : {},
  ethereumNetworks  : {},
  blockchainNetworks: {},
  formUrl           : '',
  formAction        : '',
  urlOnSuccess      : '',
  csrfToken         : ''
}
export default TokenForm
