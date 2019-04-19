import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

const Wrapper = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  font-family: Montserrat;
  font-size: 14px;
  font-weight: bold;
  color: #201662;
  padding-right: 15px;
`

const Amount = styled.div`
  margin-right: 0.5em;
`

const Currency = styled.div`
  margin-right: 0.5em;
`

const Logo = styled.img`
  height: 14px;
`

class CurrencyAmount extends React.Component {
  render() {
    return (
      <React.Fragment>
        <Wrapper>
          <Amount>
            {this.props.amount}
          </Amount>
          <Currency>
            {this.props.currency}
          </Currency>
          <Logo src={this.props.logoUrl} alt={`${this.props.currency} logo`} />
        </Wrapper>
      </React.Fragment>
    )
  }
}

CurrencyAmount.propTypes = {
  amount  : PropTypes.string.isRequired,
  currency: PropTypes.string.isRequired,
  logoUrl : PropTypes.string.isRequired
}
CurrencyAmount.defaultProps = {
  amount  : '',
  currency: '',
  logoUrl : ''
}
export default CurrencyAmount
