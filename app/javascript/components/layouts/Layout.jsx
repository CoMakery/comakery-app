import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Icon from './../styleguide/Icon'

class Layout extends React.Component {
  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
  }

  render() {
    const {
      className,
      title,
      hasBackButton,
      subfooter,
      sidebar,
      children,
      ...other
    } = this.props

    const classnames = classNames(
      'layout',
      className
    )

    return (
      <React.Fragment>
        <div className={classnames} {...other}>
          { hasBackButton &&
            <div className="layout--back-button">
              <Icon name="iconCloseCopy.svg" onClick={this.goBack} />
            </div>
          }

          <div className="layout--content">
            <div className="layout--content--title">
              {title}
            </div>

            <hr className="layout--content--hr" />

            <div className="layout--content--wrapper">
              { sidebar &&
                <div className="layout--content--sidebar">
                  {sidebar}
                </div>
              }

              <div className={sidebar ? 'layout--content--content__sidebared' : 'layout--content--content'}>
                {children}
              </div>
            </div>
          </div>

          { subfooter &&
            <div className="layout--subfooter">
              <div className="layout--subfooter--buttons">
                {subfooter}
              </div>
            </div>
          }
        </div>
      </React.Fragment>
    )
  }
}

Layout.propTypes = {
  className    : PropTypes.string,
  title        : PropTypes.string,
  hasBackButton: PropTypes.bool,
  subfooter    : PropTypes.object,
  sidebar      : PropTypes.object
}
Layout.defaultProps = {
  className    : '',
  title        : 'title',
  hasBackButton: false,
  subfooter    : null,
  sidebar      : null
}
export default Layout
