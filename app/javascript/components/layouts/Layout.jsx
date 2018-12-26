import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Icon from './../styleguide/Icon'
import ButtonBorder from './../styleguide/ButtonBorder'
import ButtonPrimaryDisabled from './../styleguide/ButtonPrimaryDisabled'
import ButtonPrimaryEnabled from './../styleguide/ButtonPrimaryEnabled'

class Layout extends React.Component {
  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
  }

  render() {
    const {
      className,
      title,
      hasBackButton,
      hasSubFooter,
      saveAndCloseButtonEnabled,
      cancelButtonHandler,
      saveButtonHandler,
      saveAndCloseButtonHandler,
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

          { hasSubFooter &&
            <div className="layout--subfooter">
              <div className="layout--subfooter--buttons">
                <ButtonBorder className="layout--subfooter--buttons--cancel" value="cancel" onClick={cancelButtonHandler} />
                <ButtonBorder className="layout--subfooter--buttons--save" value="save" onClick={saveButtonHandler} />
                { !saveAndCloseButtonEnabled &&
                  <ButtonPrimaryDisabled value="save & close" />
                }
                { saveAndCloseButtonEnabled &&
                  <ButtonPrimaryEnabled className="layout--subfooter--buttons--save-and-close" value="save & close" onClick={saveAndCloseButtonHandler} />
                }
              </div>
            </div>
          }
        </div>
      </React.Fragment>
    )
  }
}

Layout.propTypes = {
  className                : PropTypes.string,
  title                    : PropTypes.string,
  hasBackButton            : PropTypes.bool,
  hasSubFooter             : PropTypes.bool,
  saveAndCloseButtonEnabled: PropTypes.bool,
  cancelButtonHandler      : PropTypes.func,
  saveButtonHandler        : PropTypes.func,
  saveAndCloseButtonHandler: PropTypes.func,
  sidebar                  : PropTypes.object
}
Layout.defaultProps = {
  className                : '',
  title                    : 'title',
  hasBackButton            : false,
  hasSubFooter             : false,
  saveAndCloseButtonEnabled: false,
  cancelButtonHandler      : () => {},
  saveButtonHandler        : () => {},
  saveAndCloseButtonHandler: () => {},
  sidebar                  : null
}
export default Layout
