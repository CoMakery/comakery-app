import React from 'react'
import classNames from 'classnames'
import InputField from './InputField'

class InputFieldDescriptionMiddle extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'input-field__description-middle',
      className
    )

    return (
      <React.Fragment>
        <InputField
          className={classnames}
          type="textarea"
          {...other}
        />
      </React.Fragment>
    )
  }
}

export default InputFieldDescriptionMiddle
