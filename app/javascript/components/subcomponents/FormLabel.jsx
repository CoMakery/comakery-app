import React from 'react'
import PropTypes from 'prop-types'

export const FormLabel = props => {
  return <div className="mission-label">
    <div className="mission-label__title">
      {props.title}
      {props.required && <span className="mission-label__required">Required</span>}
    </div>
    {props.length && <div className="mission-label__length">{props.currentLength}/{props.length}</div>}
  </div>
}

FormLabel.propTypes = {
  title        : PropTypes.string.isRequired,
  required     : PropTypes.bool.isRequired,
  currentLength: PropTypes.number,
  length       : PropTypes.number
}
