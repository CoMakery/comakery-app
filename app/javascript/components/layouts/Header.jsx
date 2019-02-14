import React from 'react'
import classNames from 'classnames'
import PropTypes from 'prop-types'
import Icon from './../styleguide/Icon'

const navContent = (isLoggedIn, currentPath, isAdmin) => {
  return <React.Fragment>
    { !isLoggedIn &&
      <div className="header--nav--links">
        <a href="/" className={(currentPath === '/' || currentPath === '/featured') ? 'header--nav--links--current' : null}>
          Home
        </a>

        <a href="mailto:support@comakery.com">
          Contact Us
        </a>

        <a href="/session/new" className={currentPath.match(/session\/new/) ? 'header--nav--links--current header--nav--links--sign' : 'header--nav--links--sign'} >
          Sign In
        </a>

        <a href="/accounts/new" className={currentPath.match(/accounts\/new/) ? 'header--nav--links--current header--nav--links--sign' : 'header--nav--links--sign'} >
          Sign Up
        </a>
      </div>
    }

    { isLoggedIn &&
      <div className="header--nav--links">
        <a href="/" className={(currentPath === '/' || currentPath === '/featured') ? 'header--nav--links--current' : null}>
          Home
        </a>

        { isAdmin &&
          <React.Fragment>
            <a href="/missions" className={currentPath.match(/missions/) ? 'header--nav--links--current' : null}>
              Missions
            </a>

            <a href="/tokens" className={currentPath.match(/tokens/) ? 'header--nav--links--current' : null}>
              Tokens
            </a>
          </React.Fragment>
        }

        <a href="/projects/mine" className={currentPath.match(/projects/) ? 'header--nav--links--current' : null} >
          My Projects
        </a>

        <a href="/" style={{'display': 'none'}}>
          My Tasks
        </a>

        <a href="/account" className={currentPath.match(/account/) ? 'header--nav--links--current' : null} >
          My Account
        </a>

        <a rel="nofollow" href="/session" data-method="delete" className="header--nav--links--sign">
          Sign out
        </a>
      </div>
    }
  </React.Fragment>
}

class Header extends React.Component {
  constructor(props) {
    super(props)
    this.state = { mobileMenuActive: false }
  }
  render() {
    const {className, isAdmin, isLoggedIn, currentPath, ...other} = this.props

    const classnames = classNames(
      'header',
      className
    )

    const {mobileMenuActive} = this.state
    const nav = navContent(isLoggedIn, currentPath, isAdmin)

    return (
      <React.Fragment>
        <div className={classnames} {...other}>
          <div className="header--logo">
            <Icon name="Logo-Header.svg" width="200px" />
          </div>

          <div className="header--nav">
            {nav}
          </div>
        </div>

        <div className="header-mobile">
          <Icon name="Logo-Header.svg" width="162px" />

          <div className="header-mobile__menu-icon" onClick={() => {
            this.setState({mobileMenuActive: !mobileMenuActive})
            document.body.classList.toggle('body--overflow')
          }} >
            <span className={mobileMenuActive ? 'active' : ''} />
          </div>

          { mobileMenuActive &&
            <div className="header-mobile__menu">
              {nav}
              <div className="header-mobile__menu__sign">
                {isLoggedIn &&
                  <a rel="nofollow" href="/session" data-method="delete">
                    LOGOUT
                  </a>
                }
                {!isLoggedIn &&
                  <React.Fragment>
                    <a href="/session/new" className={currentPath.match(/session\/new/) ? 'header--nav--links--current' : null} >
                      Sign In
                    </a>

                    <a href="/accounts/new" className={currentPath.match(/accounts\/new/) ? 'header--nav--links--current' : null} >
                      Sign Up
                    </a>
                  </React.Fragment>
                }
              </div>
            </div>
          }
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
