import React from 'react'
import classNames from 'classnames'
import InputField from './InputField'

class Checkbox extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'checkbox',
      className
    )

    return (
      <React.Fragment>
        <InputField
          className={classnames}
          type="checkbox"
          symbolLimit={0}
          {...other}
        />
      </React.Fragment>
    )
  }
}

export default Checkbox
