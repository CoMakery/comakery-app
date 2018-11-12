import React from 'react'
import PropTypes from 'prop-types'

export default function HelloWorld(props) {
  return <div>Hello {props.greeting}!</div>
}

HelloWorld.defaultProps = {
  greeting: 'David'
}

HelloWorld.propTypes = {
  greeting: PropTypes.string
}
