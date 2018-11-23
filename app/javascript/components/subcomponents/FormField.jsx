import React from 'react'
import PropTypes from 'prop-types'

export default class FormField extends React.Component {
  render() {
    return (
      <React.Fragment>
        <div className="columns small-3">
          <label>
            {this.props.fieldLabel}
          </label>
        </div>
        <div className={`columns small-9 ${this.props.error ? 'error' : ''}`}>
          <input
            type="text"
            name={this.props.fieldName}
            value={this.props.fieldValue || ''}
            onChange={this.props.handleChange}
          />
          {this.props.error &&
          <small className="error">
            {this.props.error}
          </small>}
        </div>
      </React.Fragment>
    )
  }
}

FormField.propTypes = {
  fieldLabel  : PropTypes.string.isRequired,
  fieldName   : PropTypes.string.isRequired,
  fieldValue  : PropTypes.string,
  handleChange: PropTypes.func.isRequired,
  error       : PropTypes.string,
}
