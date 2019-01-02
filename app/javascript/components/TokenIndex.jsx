import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'

class TokenIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.state = {
      selectedToken: null
    }
  }

  handleListClick(token) {
    this.setState({
      selectedToken: token
    })
  }

  render() {
    return (
      <React.Fragment>
        <Layout
          className="token-index"
          title="Tokens"
          sidebar={
            <React.Fragment>
              <div className="token-index--sidebar">
                <SidebarItemBold
                  className="token-index--sidebar--item__bold"
                  iconLeftName="MARK-WHITE.svg"
                  iconRightName="PLUS.svg"
                  text="Create a Token"
                  onClick={(_) => window.location = '/tokens/new'}
                />

                <hr />

                { this.props.tokens.length > 0 &&
                  <React.Fragment>
                    <div className="token-index--sidebar--info">
                      Please select token:
                    </div>

                    {this.props.tokens.map((t) =>
                      <SidebarItem
                        className="token-index--sidebar--item"
                        key={t.id}
                        iconLeftUrl={t.logoUrl}
                        iconRightName="REARRANGE.svg"
                        text={`${t.name} (${t.symbol})`}
                        selected={this.state.selectedToken === t}
                        onClick={(_) => this.handleListClick(t)}
                      />
                    )}
                  </React.Fragment>
                }
              </div>
            </React.Fragment>
          }
        >
          {this.state.selectedToken &&
            <div className="token-index--view">
              <div className="token-index--view--logo">
                <img
                  src={this.state.selectedToken.logoUrl}
                />
              </div>

              <div className="token-index--view--info">
                <div className="token-index--view--info--item">
                  <div className="token-index--view--info--item--name">
                    token name
                  </div>
                  <div className="token-index--view--info--item--value">
                    {this.state.selectedToken.name}
                  </div>
                </div>

                <div className="token-index--view--info--item">
                  <div className="token-index--view--info--item--name">
                    payment type
                  </div>
                  <div className="token-index--view--info--item--value">
                    {this.state.selectedToken.coinType}
                  </div>
                </div>

                <div className="token-index--view--info--item">
                  <div className="token-index--view--info--item--name">
                    token symbol
                  </div>
                  <div className="token-index--view--info--item--value">
                    {this.state.selectedToken.symbol}
                  </div>
                </div>

                { this.state.selectedToken.contractAddress &&
                  <div className="token-index--view--info--item">
                    <div className="token-index--view--info--item--name">
                      contract address
                    </div>
                    <div className="token-index--view--info--item--value">
                      {this.state.selectedToken.contractAddress}
                    </div>
                  </div>
                }

                { this.state.selectedToken.ethereumContractAddress &&
                  <div className="token-index--view--info--item">
                    <div className="token-index--view--info--item--name">
                      contract address
                    </div>
                    <div className="token-index--view--info--item--value">
                      {this.state.selectedToken.ethereumContractAddress}
                    </div>
                  </div>
                }

                { this.state.selectedToken.blockchainNetwork &&
                  <div className="token-index--view--info--item">
                    <div className="token-index--view--info--item--name">
                      blockchain network
                    </div>
                    <div className="token-index--view--info--item--value">
                      {this.state.selectedToken.blockchainNetwork}
                    </div>
                  </div>
                }

                { this.state.selectedToken.ethereumNetwork &&
                  <div className="token-index--view--info--item">
                    <div className="token-index--view--info--item--name">
                      blockchain network
                    </div>
                    <div className="token-index--view--info--item--value">
                      {this.state.selectedToken.ethereumNetwork}
                    </div>
                  </div>
                }
              </div>

              <div className="token-index--view--link">
                <a
                  href={`/tokens/${this.state.selectedToken.id}`}
                >
                  edit token
                </a>
              </div>
            </div>
          }
        </Layout>
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
