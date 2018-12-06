import React from 'react'
import PropTypes from 'prop-types'

export default class MissionsIndex extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      ...props,
      logo       : null,
      image      : null,
      message    : null, // notify sucess or error after account info update
      messageType: 'notice',
      showMessage: false, // show or hide message
      errors     : {}, // error hash for account form
    }
    this.mounted = false
  }

  componentDidMount() {
    this.mounted = true
  }

  componentWillMount() {
    this.mounted = false
  }

  render() {
    return <React.Fragment>
      <div className="mission-container">
        <div className="mission-header" style={{fontWeight: 'normal'}}>Missions > <b>Configure mission’s landing page</b></div>
      </div>
    </React.Fragment>
  }
}
