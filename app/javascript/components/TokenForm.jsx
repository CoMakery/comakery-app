import React from "react"
import PropTypes from "prop-types"
import {fetch as fetchPolyfill} from 'whatwg-fetch'

class TokenForm extends React.Component {
  constructor(props) {
    super(props)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.state = {
      displayErrors : false
    }
  }

  handleSubmit (event) {
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
      method: this.props.formAction,
      body: data
    }).then(response => { 
      if (response.status == 201) {
        window.location = this.props.urlOnSuccess
      } else {
        // handle error response
      }
    })
  }

  render () {
    return (
      <React.Fragment>
        <form onSubmit={this.handleSubmit} noValidate className={this.state.displayErrors ? 'displayErrors' : ''}>
          <label>
            payment type
            <select
              required
              name="token[coin_type]"
              defaultValue={this.props.token.coinType || ''}
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
              defaultValue={this.props.token.name || ''}
              placeholder="Bitcoin"
            />
          </label>
            
          <label>
            token symbol
            <input
              required
              type="text"
              name="token[symbol]"
              defaultValue={this.props.token.symbol || ''}
              placeholder="BTC"
            />
          </label>
            
          <label>
            contract address
            <input
              type="text"
              name="token[contract_address]"
              defaultValue={this.props.token.contractAddress || ''}
              onChange={this.handleAddressChange}
              pattern="0x\d{40}"
              placeholder="0x6c6ee5e31d828de241282b9606c8e98ea48526e2"
            />
            <input
              type="text"
              name="token[ethereum_contract_address]"
              defaultValue={this.props.token.ethereumContractAddress || ''}
              onChange={this.handleEthereumAddressChange}
              pattern="0x\d{40}"
              placeholder="0x6c6ee5e31d828de241282b9606c8e98ea48526e2"
            />
          </label>
            
          <label>
            decimal places
            <input
              required
              type="text"
              name="token[decimal_places]"
              defaultValue={this.props.token.decimalPlaces || ''}
              placeholder="2"
            />
          </label>
              
          <label>
            blockchain network
            <select
              name="token[blockchain_network]"
              defaultValue={this.props.token.blockchainNetwork || ''}
            >
              {Object.entries(this.props.blockchainNetworks).map(([k, v]) =>
                <option key={v} value={v}>{k}</option>
              )}
            </select>
            <select
              name="token[ethereum_network]"
              defaultValue={this.props.token.ethereumNetwork || ''}
            >
              {Object.entries(this.props.ethereumNetworks).map(([k, v]) =>
                <option key={v} value={v}>{k}</option>
              )}
            </select>
          </label>
              
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
            readOnly={true}
          />

          <input
            type="submit"
            value="save"
          />
        </form>
      </React.Fragment>
    );
  }
}

TokenForm.propTypes = {
  token     : PropTypes.object.isRequired,
  coinTypes : PropTypes.object.isRequired,
  ethereumNetworks: PropTypes.object.isRequired,
  blockchainNetworks: PropTypes.object.isRequired,
  formUrl: PropTypes.string.isRequired,
  formAction: PropTypes.string.isRequired,
  urlOnSuccess: PropTypes.string.isRequired,
  csrfToken: PropTypes.string.isRequired
}
TokenForm.defaultProps = {
  token   : {},
  coinTypes : {},
  ethereumNetworks: {},
  blockchainNetworks: {},
  formUrl: "",
  formAction: "",
  urlOnSuccess: "",
  csrfToken: ""
}
export default TokenForm
