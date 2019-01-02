import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Message from './Message'

class MessageWarning extends React.Component {
  render() {
    const {className, ...other} = this.props

    const classnames = classNames(
      'message__warning',
      className
    )

    return (
      <React.Fragment>
        <Message
          className={classnames} {...other}
          severity="warning"
        />
      </React.Fragment>
    )
  }
}

MessageWarning.propTypes = {
  className: PropTypes.string,
  text     : PropTypes.string
}
MessageWarning.defaultProps = {
  className: '',
  text     : 'warning text'
}
export default MessageWarning
