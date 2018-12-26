import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Icon from './Icon'

class Message extends React.Component {
  constructor(props) {
    super(props)
    this.hide = this.hide.bind(this)
    this.state = {
      hidden: false
    }
  }

  hide() {
    this.setState({
      hidden: true
    })
  }

  render() {
    const {className, severity, text, ...other} = this.props

    const classnames = classNames(
      'message',
      className
    )

    return (
      <React.Fragment>
        {!this.state.hidden &&
          <div className="message--wrapper--block">
            <div className="message--wrapper--inline">
              <div className={classnames} {...other}>
                <span className="message--icon">
                  { severity === 'warning' &&
                    <Icon name="atomsIconsSystemChat.svg" width={21} />
                  }
                  { severity === 'error' &&
                    <Icon name="atomsIconsSystemChat.svg" width={21} />
                  }
                </span>
                <span className={`message--text__${severity}`}>
                  {text}
                </span>
                <span className="message--close-icon" onClick={this.hide} >
                  <Icon name="iconCloseDark.svg" width={24} />
                </span>
              </div>
            </div>
          </div>
        }
      </React.Fragment>
    )
  }
}

Message.propTypes = {
  className: PropTypes.string,
  severity : PropTypes.string,
  text     : PropTypes.string
}
Message.defaultProps = {
  className: '',
  severity : 'warning',
  text     : 'warning text'
}
export default Message
