import React from 'react'
import classNames from 'classnames'
import PropTypes from 'prop-types'
import Icon from './../styleguide/Icon'

class Header extends React.Component {
  render() {
    const {className, isAdmin, isLoggedIn, currentPath, ...other} = this.props

    const classnames = classNames(
      'header',
      className
    )

    return (
      <React.Fragment>
        <div className={classnames} {...other}>
          <div className="header--logo">
            <Icon name="Logo-Header.svg" width="200px" />
          </div>

          <div className="header--nav">
            { !isLoggedIn &&
              <div className="header--nav--links">
                <a href="mailto:support@comakery.com">
                  Contact Us
                </a>

                <a href="/session/new" className={currentPath.match(/session\/new/) ? 'header--nav--links--current' : null} >
                  Sign In
                </a>

                <a href="/accounts/new" className={currentPath.match(/accounts\/new/) ? 'header--nav--links--current' : null} >
                  Sign Up
                </a>
              </div>
            }

            { isLoggedIn &&
              <div className="header--nav--links">
                <a href="/" className={currentPath === '/' ? 'header--nav--links--current' : null}>
                  Home
                </a>

                { isAdmin &&
                  <React.Fragment>
                    <a href="/">
                      Missions
                    </a>

                    <a href="/tokens" className={currentPath.match(/tokens/) ? 'header--nav--links--current' : null}>
                      Tokens
                    </a>
                  </React.Fragment>
                }

                <a href="/projects/mine" className={currentPath.match(/projects\/mine/) ? 'header--nav--links--current' : null} >
                  My Projects
                </a>

                <a href="/" style={{'display': 'none'}}>
                  My Tasks
                </a>

                <a href="/account" className={currentPath.match(/account/) ? 'header--nav--links--current' : null} >
                  My Account
                </a>

                <a rel="nofollow" href="/session" data-method="delete">
                  Sign out
                </a>
              </div>
            }
          </div>
        </div>
      </React.Fragment>
    )
  }
}
Header.propTypes = {
  currentPath: PropTypes.string,
  isAdmin    : PropTypes.bool,
  isLoggedIn : PropTypes.bool
}
Header.defaultProps = {
  currentPath: '/',
  isAdmin    : false,
  isLoggedIn : false
}
export default Header
