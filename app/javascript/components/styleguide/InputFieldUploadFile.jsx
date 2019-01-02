import React from 'react'
import classNames from 'classnames'
import InputField from './InputField'

class InputFieldUploadFile extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'input-field__upload-file',
      className
    )

    return (
      <React.Fragment>
        <InputField
          className={classnames}
          type="file"
          symbolLimit={0}
          {...other}
        />
      </React.Fragment>
    )
  }
}

export default InputFieldUploadFile
