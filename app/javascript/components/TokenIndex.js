import React from "react"
import PropTypes from "prop-types"

class TokenIndex extends React.Component {
  render () {
    return (
      <React.Fragment>
        {this.props.tokens.map((t) =>
          <p key={t.name}>{t.name} – {t.id}</p>
        )}
      </React.Fragment>
    );
  }
}

TokenIndex.propTypes = {
  tokens   : PropTypes.array.isRequired
}
TokenIndex.defaultProps = {
  tokens   : []
}
export default TokenIndex
