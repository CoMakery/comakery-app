import React from 'react'
import classNames from 'classnames'
import InputField from './InputField'

class InputFieldWhiteDark extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'input-field__white__dark',
      className
    )

    return (
      <React.Fragment>
        <InputField
          className={classnames}
          type="text"
          {...other}
        />
      </React.Fragment>
    )
  }
}

export default InputFieldWhiteDark
