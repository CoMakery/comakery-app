import React from 'react'
import PropTypes from 'prop-types'

class TokenIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.state = {
      selectedToken: null
    }
  }

  componentDidUpdate() {
    console.log(this.state)
  }

  handleListClick(event) {
    console.log(event.target.id)
    this.setState({
      selectedToken: this.props.tokens.find((t) =>
        t.id === event.target.id
      )
    })
  }

  render() {
    return (
      <React.Fragment>
        <h1>
          tokens
        </h1>
        <p>
          <a
            href="/tokens/new"
          >
            create a token
          </a>
        </p>
        <p>
          please select a token:
        </p>

        {this.props.tokens.map((t) =>
          <input
            type="button"
            key={t.id}
            id={t.id}
            value={`${t.name} (${t.symbol})`}
            onClick={this.handleListClick}
          />
        )}

        {this.state.selectedToken &&
          <div>
            <div>
              <img
                src={this.state.selectedToken.logoUrl}
              />
            </div>
            <div>
              token name:
              {this.state.selectedToken.name}
            </div>
            <div>
              payment type:
              {this.state.selectedToken.coinType}
            </div>
            <div>
              token symbol:
              {this.state.selectedToken.symbol}
            </div>
            <div>
              contract address:
              {this.state.selectedToken.contractAddress}
            </div>
            <div>
              contract address:
              {this.state.selectedToken.ethereumContractAddress}
            </div>
            <div>
              blockchain network:
              {this.state.selectedToken.blockchainNetwork}
            </div>
            <div>
              blockchain network:
              {this.state.selectedToken.ethereumNetwork}
            </div>
            <div>
              <a
                href={`/tokens/${this.state.selectedToken.id}`}
              >
                edit token
              </a>
            </div>
          </div>
        }
      </React.Fragment>
    )
  }
}

TokenIndex.propTypes = {
  tokens: PropTypes.array.isRequired
}
TokenIndex.defaultProps = {
  tokens: []
}
export default TokenIndex
