import React from 'react'
import classNames from 'classnames'
import SidebarItem from './SidebarItem'

class SidebarItemBold extends React.Component {
  render() {
    const {
      className,
      ...other
    } = this.props

    const classnames = classNames(
      'sidebar-item__bold',
      className
    )

    return (
      <React.Fragment>
        <SidebarItem className={classnames} {...other} />
      </React.Fragment>
    )
  }
}

export default SidebarItemBold
