import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'

class Icon extends React.Component {
  render() {
    const {className, name, ...other} = this.props

    const classnames = classNames(
      'icon',
      `icon__${name.replace('.', '-')}`,
      className
    )

    return (
      <React.Fragment>
        <img className={classnames} {...other}
          src={require(`src/images/styleguide/icons/${name}`)}
        />
      </React.Fragment>
    )
  }
}

Icon.propTypes = {
  className: PropTypes.string,
  name     : PropTypes.string
}
Icon.defaultProps = {
  className: '',
  name     : 'atomsIconsSystemHeart.svg'
}
export default Icon
