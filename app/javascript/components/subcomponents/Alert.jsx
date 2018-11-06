import React from 'react'
import PropTypes from 'prop-types'

export default class Alert extends React.Component {
  render() {
    return (
      <div className={`large-10 medium-11 small-12 small-centered columns ${this.props.isVisible ? '' : 'hide'}`}>
        <div className={`callout flash-msg ${this.props.messageType}`} style={{ paddingRight: 30 }}>
          <button className="close-button float-right" onClick={this.props.toggleVisible}>
            <span>x</span>
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
  toggleVisible: PropTypes.func.isRequired,
}
