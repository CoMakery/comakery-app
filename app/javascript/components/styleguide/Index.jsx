import React from "react"
import PropTypes from "prop-types"
import Button from "./Button"
import ButtonBorder from "./ButtonBorder"
import ButtonPrimaryDisabled from "./ButtonPrimaryDisabled"
import ButtonPrimaryEnabled from "./ButtonPrimaryEnabled"

class Index extends React.Component {
  render () {
    return (
      <React.Fragment>
        <Button/>
        <ButtonBorder/>
        <ButtonPrimaryDisabled/>
        <ButtonPrimaryEnabled/>
      </React.Fragment>
    )
  }
}

export default Index
