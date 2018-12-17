import React from 'react'
import classNames from 'classnames'
import InputField from './InputField'

class InputFieldDropdownHalfed extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'input-field__dropdown--halfed',
      className
    )

    return (
      <React.Fragment>
        <InputField
          className={classnames}
          type="select"
          symbolLimit={0}
          {...other}
        />
      </React.Fragment>
    )
  }
}

export default InputFieldDropdownHalfed
