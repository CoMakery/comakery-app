import React from 'react'
import classNames from 'classnames'
import PropTypes from 'prop-types'
import Icon from './../styleguide/Icon'

export default class Flash extends React.Component {
  constructor(props) {
    super(props)
    this.state = { isActive: true }
  }

  componentWillReceiveProps() {
    this.setState({ isActive: true })
  }

  render() {
    const { className, flashType, message } = this.props

    const classnames = classNames(
      'flash-message',
      `flash-message--${flashType}`,
      className
    )

    return (
      <React.Fragment>
        {
          this.state.isActive &&
          <div className={classnames} >
            <Icon className="flash-message__icon" name={`flash/${flashType}.svg`} />
            <div className="flash-message__text" dangerouslySetInnerHTML={{ __html: message }} />
            <Icon className="flash-message__icon flash-message__icon--close" name="flash/close.svg" onClick={() => { this.setState({ isActive: false }) }} />
          </div>
        }
      </React.Fragment>
    )
  }
}

Flash.propTypes = {
  className: PropTypes.string,
  flashType: PropTypes.string,
  message  : PropTypes.string
}
Flash.defaultProps = {
  className: '',
  flashType: 'notice',
  message  : ''
}
