import React from 'react'
import PropTypes from 'prop-types'

class ProjectSetupHeader extends React.Component {
  render() {
    const {projectId, projectTitle, projectPage, projectOwner} = this.props

    return (
      <React.Fragment>
        <div className="layout--content--title--header">
          {projectTitle}
        </div>

        {projectOwner &&
          <span className={projectPage === 'form' ? 'layout--content--title--nav__current' : 'layout--content--title--nav'}>
            <a href={projectId ? `/projects/${projectId}/edit` : '#'}>
              project settings
            </a>
          </span>
        }

        <span className={projectPage === 'batches' ? 'layout--content--title--nav__current' : 'layout--content--title--nav'}>
          <a href={projectId ? `/projects/${projectId}/batches` : '#'}>
            batches & tasks
          </a>
        </span>

        <span className={projectPage === 'contributors' ? 'layout--content--title--nav__current' : 'layout--content--title--nav'}>
          <a href={projectId ? `/projects/${projectId}/contributors` : '#'}>
            contributors
          </a>
        </span>

        <span className={projectPage === 'awards' ? 'layout--content--title--nav__current' : 'layout--content--title--nav'}>
          <a href={projectId ? `/projects/${projectId}/awards` : '#'}>
            payments
          </a>
        </span>

        <span className={'layout--content--title--nav'}>
          <a href={projectId ? `/projects/${projectId}/` : '#'}>
            overview
          </a>
        </span>
      </React.Fragment>
    )
  }
}
ProjectSetupHeader.propTypes = {
  projectId   : PropTypes.number,
  projectTitle: PropTypes.string,
  projectPage : PropTypes.string,
  projectOwner: PropTypes.bool,
}
ProjectSetupHeader.defaultProps = {
  projectId   : null,
  projectTitle: '',
  projectPage : '',
  projectOwner: true,
}
export default ProjectSetupHeader
