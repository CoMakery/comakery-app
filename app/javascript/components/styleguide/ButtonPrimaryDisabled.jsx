import React from "react"
import PropTypes from "prop-types"
import classNames from "classnames"
import Button from "./Button"

class ButtonPrimaryDisabled extends React.Component {
  render () {
    const {className, ...other} = this.props

    const classnames = classNames(
      'button__primary__disabled',
      className
    )

    return (
      <React.Fragment>
        <Button className={classnames} disabled={true} {...other}/>
      </React.Fragment>
    )
  }
}

ButtonPrimaryDisabled.propTypes = {
  className: PropTypes.string
}
ButtonPrimaryDisabled.defaultProps = {
  className: ''
}
export default ButtonPrimaryDisabled
