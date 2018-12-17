import React from 'react'
import classNames from 'classnames'
import InputField from './InputField'

class InputFieldDefined extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'input-field__defined',
      className
    )

    return (
      <React.Fragment>
        <InputField
          className={classnames}
          type="defined"
          symbolLimit={0}
          {...other}
        />
      </React.Fragment>
    )
  }
}

export default InputFieldDefined
