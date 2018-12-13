import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Button from './Button'

class ButtonBorder extends React.Component {
  render() {
    const {className, ...other} = this.props

    const classnames = classNames(
      'button__border',
      className
    )

    return (
      <React.Fragment>
        <Button className={classnames} {...other} />
      </React.Fragment>
    )
  }
}

ButtonBorder.propTypes = {
  className: PropTypes.string
}
ButtonBorder.defaultProps = {
  className: ''
}
export default ButtonBorder
