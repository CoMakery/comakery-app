import React from 'react'
import classNames from 'classnames'
import PropTypes from 'prop-types'
import Icon from './../styleguide/Icon'

class Footer extends React.Component {
  render() {
    const {className, isLoggedIn, ...other} = this.props

    const classnames = classNames(
      'footer',
      className
    )

    return (
      <React.Fragment>
        <div className={classnames} {...other}>
          <div className="footer--logo">
            <Icon name="Logo-Footer.svg" width="170px" />
          </div>

          <div className="footer--content">
            <div className="footer--content--text">
            CoMakery helps you gather a tribe to achieve big missions.
            <br />
            To achieve your big mission you need to bring people together around a common vision, let them know what they will get by contributing, and organize the work. The CoMakery platform helps you do this with missions, projects, task workflows, tokens & payments.
            </div>

            <div className="footer--content--nav">
              <div className="footer--content--nav--about">
                <div className="footer--content--nav--about--header">
                  About CoMakery
                </div>
                <a href="/">
                  Home
                </a>
                <a className="intercom" href="">
                  Contact Us
                </a>
              </div>

              { !isLoggedIn &&
                <div className="footer--content--nav--join">
                  <div className="footer--content--nav--join--header">
                    Join
                  </div>
                  <a href="/accounts/new">
                    Contributors
                  </a>
                  <a href="/accounts/new">
                    Foundations
                  </a>
                </div>
              }

              <div className="footer--content--nav--legal">
                <div className="footer--content--nav--legal--header">
                  Legal
                </div>
                <a href="/user-agreement">
                  User Agreement
                </a>
                <a href="/prohibited-use">
                  Prohibited Use
                </a>
                <a href="/e-sign-disclosure">
                  E-Sign Disclosure
                </a>
                <a href="/privacy-policy">
                  Privacy Policy
                </a>
              </div>
            </div>
          </div>

          <div className="footer--copyright">
            © {(new Date()).getFullYear()} CoMakery, Inc. All rights reserved.
          </div>
        </div>
      </React.Fragment>
    )
  }
}
Footer.propTypes = {
  isLoggedIn: PropTypes.bool
}
Footer.defaultProps = {
  isLoggedIn: false
}
export default Footer
