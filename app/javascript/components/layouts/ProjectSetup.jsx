import React from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'
import Layout from './Layout'
import ProjectSetupHeader from './ProjectSetupHeader'

class ProjectSetup extends React.Component {
  render() {
    const classnames = classNames(
      'project-setup',
      this.props.className
    )

    return (
      <React.Fragment>
        <Layout
          className={classnames}
          customTitle={
            <ProjectSetupHeader
              projectForHeader={this.props.projectForHeader}
              missionForHeader={this.props.missionForHeader}
              owner={this.props.owner}
              current={this.props.current}
            />
          }
          sidebar={this.props.sidebar}
          subfooter={this.props.subfooter}
        >
          {this.props.children}
        </Layout>
      </React.Fragment>
    )
  }
}

ProjectSetup.propTypes = {
  className       : PropTypes.string,
  subfooter       : PropTypes.object,
  sidebar         : PropTypes.object,
  missionForHeader: PropTypes.object,
  projectForHeader: PropTypes.object,
  owner           : PropTypes.bool,
  current         : PropTypes.string
}
ProjectSetup.defaultProps = {
  className       : PropTypes.string,
  subfooter       : null,
  sidebar         : null,
  missionForHeader: null,
  projectForHeader: null,
  owner           : true,
  current         : ''
}
export default ProjectSetup
