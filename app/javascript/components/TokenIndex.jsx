import React from 'react'
import PropTypes from 'prop-types'

class TokenIndex extends React.Component {
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
          <div key={t.id}>
            <div>
              <img
                src={t.logoUrl}
              />
            </div>
            <div>
              token name:
              {t.name}
            </div>
            <div>
              payment type:
              {t.coinType}
            </div>
            <div>
              token symbol:
              {t.symbol}
            </div>
            <div>
              contract address:
              {t.contractAddress}
            </div>
            <div>
              contract address:
              {t.ethereumContractAddress}
            </div>
            <div>
              blockchain network:
              {t.blockchainNetwork}
            </div>
            <div>
              blockchain network:
              {t.ethereumNetwork}
            </div>
            <div>
              <a
                href={`/tokens/${t.id}`}
              >
                edit token
              </a>
            </div>
          </div>
        )}
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
