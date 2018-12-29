import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Icon from './Icon'

class SidebarItem extends React.Component {
  render() {
    const {
      className,
      iconLeftUrl,
      iconLeftName,
      iconRightName,
      text,
      selected,
      ...other
    } = this.props

    const classnames = classNames(
      'sidebar-item',
      (selected ? 'sidebar-item__selected' : ''),
      className
    )

    return (
      <React.Fragment>
        <div className="sidebar-item--wrapper" {...other}>
          <div className={classnames}>
            { (iconLeftUrl || iconLeftName) &&
              <span className="sidebar-item--icon-left">
                { iconLeftUrl !== '' &&
                  <img src={iconLeftUrl} />
                }
                { iconLeftName !== '' &&
                  <Icon name={iconLeftName} />
                }
              </span>
            }

            <span className="sidebar-item--text">
              {text}
            </span>

            { iconRightName !== '' &&
              <span className="sidebar-item--icon-right">
                <Icon name={iconRightName} />
              </span>
            }
          </div>
        </div>
      </React.Fragment>
    )
  }
}

SidebarItem.propTypes = {
  className    : PropTypes.string,
  iconLeftUrl  : PropTypes.string,
  iconLeftName : PropTypes.string,
  iconRightName: PropTypes.string,
  text         : PropTypes.string,
  selected     : PropTypes.bool
}
SidebarItem.defaultProps = {
  className    : '',
  iconLeftUrl  : '',
  iconLeftName : '',
  iconRightName: '',
  text         : 'sidebar item',
  selected     : false
}
export default SidebarItem
