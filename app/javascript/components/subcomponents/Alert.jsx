import React from 'react'
import PropTypes from 'prop-types'

export default class Alert extends React.Component {
  render() {
    return (
      <div className={`large-12 medium-12 small-12 small-centered ${this.props.isVisible ? '' : 'hide'}`}
        style={{ position: 'absolute', left: 0, top: 60, width: '100%' }}>
        <div className={`callout flash-msg ${this.props.messageType}`} style={{ paddingRight: 30 }}>
          <button className="close-button float-right" onClick={this.props.toggleVisible}>
            <span>&times;</span>
          </button>
          <span>
            {this.props.message}
          </span>
        </div>
      </div>
    )
  }
}

Alert.propTypes = {
  message      : PropTypes.string,
  messageType  : PropTypes.string.isRequired,
  isVisible    : PropTypes.bool.isRequired,
  toggleVisible: PropTypes.func.isRequired
}
