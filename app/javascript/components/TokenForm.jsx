import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'

class TokenForm extends React.Component {
  constructor(props) {
    super(props)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)
    this.state = {
      displayErrors                     : false,
      symbolEditable                    : true,
      decimalPlacesEditable             : true,
      'token[coin_type]'                : this.props.token.coinType || Object.values(this.props.coinTypes)[0],
      'token[name]'                     : this.props.token.name || '',
      'token[symbol]'                   : this.props.token.symbol || '',
      'token[contract_address]'         : this.props.token.contractAddress || '',
      'token[ethereum_contract_address]': this.props.token.ethereumContractAddress || '',
      'token[decimal_places]'           : this.props.token.decimalPlaces || '',
      'token[blockchain_network]'       : this.props.token.blockchainNetwork || Object.values(this.props.blockchainNetworks)[0],
      'token[ethereum_network]'         : this.props.token.ethereumNetwork || Object.values(this.props.ethereumNetworks)[0]
    }
  }

  handleFieldChange(event) {
    this.setState({ [event.target.name]: event.target.value })
  }

  componentDidUpdate() {
    console.log(this.state)
  }

  handleSubmit(event) {
    event.preventDefault()

    if (event.target.checkValidity()) {
      this.setState({ displayErrors: false })
    } else {
      this.setState({ displayErrors: true })
      return
    }

    const data = new FormData(event.target)

    fetchPolyfill(this.props.formUrl, {
      credentials: 'same-origin',
      method     : this.props.formAction,
      body       : data
    }).then(response => {
      if (response.status === 201) {
        window.location = this.props.urlOnSuccess
      } else {
        // handle error response
      }
    })
  }

  render() {
    return (
      <React.Fragment>
        <form onSubmit={this.handleSubmit} noValidate className={this.state.displayErrors ? 'displayErrors' : ''}>
          <label>
            payment type
            <select
              required
              name="token[coin_type]"
              value={this.state['token[coin_type]']}
              onChange={this.handleFieldChange}
            >
              {Object.entries(this.props.coinTypes).map(([k, v]) =>
                <option key={v} value={v}>{k}</option>
              )}
            </select>
          </label>

          <label>
            token name
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
              <input
                required
                type="text"
                name="token[symbol]"
                value={this.state['token[symbol]']}
                onChange={this.handleFieldChange}
                placeholder="BTC"
              />
            </label>
          }

          {this.state['token[coin_type]'] === 'qrc20' &&
            <label>
              contract address
              <input
                type="text"
                name="token[contract_address]"
                value={this.state['token[contract_address]']}
                onChange={this.handleFieldChange}
                pattern="[a-fA-F0-9]{40}"
                placeholder="2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc"
              />
            </label>
          }

          {this.state['token[coin_type]'] === 'erc20' &&
            <label>
              contract address
              <input
                type="text"
                name="token[ethereum_contract_address]"
                value={this.state['token[ethereum_contract_address]']}
                onChange={this.handleFieldChange}
                pattern="0x[a-fA-F0-9]{40}"
                placeholder="0x6c6ee5e31d828de241282b9606c8e98ea48526e2"
              />
            </label>
          }

          {this.state['token[coin_type]'].match(/qrc20|erc20/) &&
            <label>
              decimal places
              <input
                required
                type="number"
                min="0"
                max="100"
                name="token[decimal_places]"
                value={this.state['token[decimal_places]']}
                onChange={this.handleFieldChange}
                placeholder="2"
              />
            </label>
          }

          {this.state['token[coin_type]'] === 'qrc20' &&
            <label>
              blockchain network
              <select
                name="token[blockchain_network]"
                value={this.state['token[blockchain_network]']}
                onChange={this.handleFieldChange}
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
              <select
                name="token[ethereum_network]"
                value={this.state['token[ethereum_network]']}
                onChange={this.handleFieldChange}
              >
                {Object.entries(this.props.ethereumNetworks).map(([k, v]) =>
                  <option key={v} value={v}>{k}</option>
                )}
              </select>
            </label>
          }

          <label>
            token logo
            <input
              required
              type="file"
              name="token[logo_image]"
              onChange={this.handleLogoChange}
            />
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
