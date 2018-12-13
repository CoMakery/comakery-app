import React from "react"
import PropTypes from "prop-types"
import classNames from "classnames"

class Button extends React.Component {
  render () {
    const {className, type, value, disabled, ...other} = this.props

    const classnames = classNames(
      'button',
      className
    )

    return (
      <React.Fragment>
        <input className={classnames} {...other}
          type={type}
          value={value}
          disabled={disabled}
        />
      </React.Fragment>
    )
  }
}

Button.propTypes = {
  className: PropTypes.string,
  type: PropTypes.string,
  value: PropTypes.string,
  disabled: PropTypes.bool
}
Button.defaultProps = {
  className: '',
  type: 'button',
  value: 'publish',
  disabled: false
}
export default Button
