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
              CoMakery accelerates blockchain protocol adoption with scalable teams of talented makers. We build communities of high-level, distributed engineers, designers, and community managers, and match them with unique blockchain projects.
            </div>

            <div className="footer--content--nav">
              <div className="footer--content--nav--about">
                <div className="footer--content--nav--about--header">
                  About CoMakery
                </div>
                <a href="/">
                  Home
                </a>
                <a href="mailto:support@comakery.com">
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
