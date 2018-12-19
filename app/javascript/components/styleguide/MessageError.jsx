import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Message from './Message'

class MessageError extends React.Component {
  render() {
    const {className, ...other} = this.props

    const classnames = classNames(
      'message__error',
      className
    )

    return (
      <React.Fragment>
        <Message
          className={classnames} {...other}
          severity="error"
        />
      </React.Fragment>
    )
  }
}

MessageError.propTypes = {
  className: PropTypes.string,
  text     : PropTypes.string
}
MessageError.defaultProps = {
  className: '',
  text     : 'error text'
}
export default MessageError
