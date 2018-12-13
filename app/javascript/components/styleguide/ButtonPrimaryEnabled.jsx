import React from "react"
import PropTypes from "prop-types"
import classNames from "classnames"
import Button from "./Button"

class ButtonPrimaryEnabled extends React.Component {
  render () {
    const {className, ...other} = this.props

    const classnames = classNames(
      'button__primary__enabled',
      className
    )

    return (
      <React.Fragment>
        <Button className={classnames} {...other}/>
      </React.Fragment>
    )
  }
}

ButtonPrimaryEnabled.propTypes = {
  className: PropTypes.string
}
ButtonPrimaryEnabled.defaultProps = {
  className: ''
}
export default ButtonPrimaryEnabled
