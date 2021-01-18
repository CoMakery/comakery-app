import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'
import styled from "styled-components";

const Pagination = styled.div`
  text-align: right;
  width: 100%;
  padding: 15px 0;
`

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
          className='token-index'
          title='Tokens'
          sidebar={
            <React.Fragment>
              <div className='token-index--sidebar'>
                <a href='/tokens/new'>
                  <SidebarItemBold
                    className='token-index--sidebar--item__bold'
                    iconLeftName='MARK-WHITE.svg'
                    iconRightName='PLUS.svg'
                    text='Create a Token'
                  />
                </a>

                { this.props.tokens.length > 0 &&
                  <React.Fragment>
                    <hr />

                    <div className='token-index--sidebar--info'>
                      Please select token:
                    </div>

                    {this.props.tokens.map((t) =>
                      <SidebarItem
                        className='token-index--sidebar--item'
                        key={t.id}
                        iconLeftUrl={t.logoUrl}
                        text={t.symbol ? `${t.name} (${t.symbol})` : `${t.name}`}
                        selected={this.state.selectedToken === t}
                        onClick={(_) => this.handleListClick(t)}
                      />
                    )}
                  </React.Fragment>
                }

                <Pagination dangerouslySetInnerHTML={{__html: this.props.paginationHtml}} />
              </div>
            </React.Fragment>
          }
        >
          {this.state.selectedToken &&
            <div className='token-index--view'>
              <div className='token-index--view--logo'>
                <img
                  src={this.state.selectedToken.logoUrl}
                />
              </div>

              <div className='token-index--view--info'>
                <div className='token-index--view--info--item'>
                  <div className='token-index--view--info--item--name'>
                    token name
                  </div>
                  <div className='token-index--view--info--item--value'>
                    {this.state.selectedToken.name}
                  </div>
                </div>

                <div className='token-index--view--info--item'>
                  <div className='token-index--view--info--item--name'>
                    token type
                  </div>
                  <div className='token-index--view--info--item--value'>
                    {this.state.selectedToken.TokenType.toUpperCase()}
                  </div>
                </div>

                <div className='token-index--view--info--item'>
                  <div className='token-index--view--info--item--name'>
                    blockchain network
                  </div>
                  <div className='token-index--view--info--item--value'>
                    {this.state.selectedToken.Blockchain}
                  </div>
                </div>

                { this.state.selectedToken.symbol &&
                  <div className='token-index--view--info--item'>
                    <div className='token-index--view--info--item--name'>
                      token symbol
                    </div>
                    <div className='token-index--view--info--item--value'>
                      {this.state.selectedToken.symbol}
                    </div>
                  </div>
                }

                { this.state.selectedToken.contractAddress &&
                  <div className='token-index--view--info--item'>
                    <div className='token-index--view--info--item--name'>
                      contract address
                    </div>
                    <div className='token-index--view--info--item--value'>
                      {this.state.selectedToken.contractAddress}
                    </div>
                  </div>
                }

                { this.state.selectedToken._blockchain &&
                  <div className='token-index--view--info--item'>
                    <div className='token-index--view--info--item--name'>
                      blockchain network
                    </div>
                    <div className='token-index--view--info--item--value'>
                      { (() => {
                        switch (this.state.selectedToken._blockchain) {
                          case 'qtum':
                            return 'Main QTUM Network'
                          case 'qtum_test':
                            return 'Test QTUM Network'
                          default:
                            return this.state.selectedToken._blockchain
                        }
                      })()
                      }
                    </div>
                  </div>
                }
              </div>

              <div className='token-index--view--link'>
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
  tokens: PropTypes.array.isRequired,
  paginationHtml: PropTypes.string.isRequired,
}
TokenIndex.defaultProps = {
  tokens: [],
  paginationHtml: ''
}
export default TokenIndex
