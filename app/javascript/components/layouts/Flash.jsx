import React from 'react'
import classNames from 'classnames'
import PropTypes from 'prop-types'
import Icon from './../styleguide/Icon'
import { FLASH_ADD_MESSAGE } from '../../src/javascripts/eventTypes'
import PubSub from 'pubsub-js'


export default class Flash extends React.Component {
  constructor(props) {
    super(props)

    this.closeMessage = this.closeMessage.bind(this)
    this.addMessage = this.addMessage.bind(this)

    PubSub.subscribe(FLASH_ADD_MESSAGE, this.addMessage);

    this.state = {
      messages: this.props.messages
    }
  }

  componentWillReceiveProps(props) {
    this.setState({
      messages: props.messages
    })
  }

  addMessage(_, message) {
    let messages = this.state.messages;
    messages.push(message);

    this.setState({
      messages: messages
    })
  }

  closeMessage(i) {
    let messages = this.state.messages
    messages.splice(i, 1)

    this.setState({
      messages: messages
    })
  }

  render() {
    const { className } = this.props

    return (
      <React.Fragment>
        <div className="flash-message-container">
          {this.state.messages.map((message, i) =>
            <div
              key={i}
              className={classNames(
                'flash-message',
                `flash-message--${message.severity}`,
                className
              )}
            >
              <Icon
                className="flash-message__icon"
                name={`flash/${message.severity}.svg`}
              />

              <div
                className="flash-message__text"
                dangerouslySetInnerHTML={{ __html: message.text }}
              />

              <Icon
                className="flash-message__icon flash-message__icon--close"
                name="flash/close.svg"
                onClick={() => { this.closeMessage(i) }}
              />
            </div>
          )}
        </div>
      </React.Fragment>
    )
  }
}

Flash.propTypes = {
  className: PropTypes.string,
  messages : PropTypes.array
}
Flash.defaultProps = {
  className: '',
  messages : [
    {
      'severity': 'warning',
      'text'    : 'warning text'
    }
  ]
}
