import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Icon from './Icon'

class SidebarItem extends React.Component {
  render() {
    const {
      className,
      iconLeftUrl,
      leftChild,
      iconLeftName,
      iconRightName,
      text,
      subchild,
      notificationColor,
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

            { leftChild }

            <div className="sidebar-item--content">
              <div className="sidebar-item--text">
                {text}
              </div>

              <div className="sidebar-item--subchild">
                {subchild}
              </div>
            </div>

            { iconRightName !== '' &&
              <span className="sidebar-item--icon-right">
                <Icon name={iconRightName} />
              </span>
            }

            <div className="sidebar-item--left-border" />

            <div className={`sidebar-item--right-border sidebar-item--right-border__${notificationColor}`} />
          </div>
        </div>
      </React.Fragment>
    )
  }
}

SidebarItem.propTypes = {
  className        : PropTypes.string,
  iconLeftUrl      : PropTypes.string,
  iconLeftName     : PropTypes.string,
  iconRightName    : PropTypes.string,
  text             : PropTypes.string,
  subchild         : PropTypes.node,
  notificationColor: PropTypes.string,
  selected         : PropTypes.bool,
  leftChild        : PropTypes.node
}
SidebarItem.defaultProps = {
  className        : '',
  iconLeftUrl      : '',
  iconLeftName     : '',
  iconRightName    : '',
  text             : 'sidebar item',
  notificationColor: '',
  selected         : false
}
export default SidebarItem
