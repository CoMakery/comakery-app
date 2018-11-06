import React from 'react'
import PropTypes from 'prop-types'

export default class DataField extends React.Component {
  render() {
    return (
      <div className="row">
        <div className="columns small-3">
          {this.props.fieldName}
        </div>
        <div className="columns small-9">
          {this.props.fieldValue}
        </div>
      </div>
    )
  }
}

DataField.propTypes = {
  fieldName : PropTypes.string,
  fieldValue: PropTypes.string,
}
