import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Button from './Button'

class ButtonBorderGray extends React.Component {
  render() {
    const {className, ...other} = this.props

    const classnames = classNames(
      'button__border__gray',
      className
    )

    return (
      <React.Fragment>
        <Button className={classnames} {...other} />
      </React.Fragment>
    )
  }
}

ButtonBorderGray.propTypes = {
  className: PropTypes.string
}
ButtonBorderGray.defaultProps = {
  className: ''
}
export default ButtonBorderGray
