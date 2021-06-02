import React from 'react'
import PropTypes from 'prop-types'
import ProjectRolesController from '../controllers/project_roles_controller'

export default class FeaturedMission extends React.Component {
  constructor(props) {
    super(props)

    this.addProjectRole = this.addProjectRole.bind(this)
    this.removeProjectRole = this.removeProjectRole.bind(this)
    this.state = {
      name       : props.name,
      description: props.description,
      imageUrl   : props.imageUrl,
      projects   : props.projects
    }
  }

  addProjectRole(projectId) {
    new ProjectRolesController().follow(projectId).then(response => {
      if (response.status === 200) {
        let newProjects = Array.from(this.state.projects)
        const index = newProjects.findIndex(project => project.id === projectId)
        newProjects[index].involved = true
        this.setState({projects: newProjects})
      } if (response.status === 401) {
        window.location = '/accounts/new'
      } else {
        throw Error(response.text())
      }
    })
  }

  removeProjectRole(projectId) {
    new ProjectRolesController().unfollow(projectId).then(response => {
      if (response.status === 200) {
        let newProjects = Array.from(this.state.projects)
        const index = newProjects.findIndex(project => project.id === projectId)
        newProjects[index].involved = false
        this.setState({ projects: newProjects })
      } else if (response.status === 401) {
        window.location = '/accounts/new'
      } else {
        throw Error(response.text())
      }
    })
  }

  render() {
    const { name, description, imageUrl, projects } = this.state
    const { missionUrl } = this.props

    return (
      <div className={`featured-mission ${this.props.float === 'right' ? 'featured-mission--right' : ''}`}>
        <a href={missionUrl} className={`featured-mission__image ${this.props.float === 'right' ? 'featured-mission__image--right' : ''}`}>
          <img src={imageUrl} />
          <span>view mission</span>
        </a>
        <div className='featured-mission__detail'>
          <div className='featured-mission__name'>
            <a href={missionUrl}>{name}</a>
          </div>
          <div className='featured-mission__description'>{description}</div>
          {projects.map(project => <div key={project.id} className='featured-mission__project'>
            <a href={`/projects/${project.id}`} className='featured-mission__project__title'>{project.title}</a>
            {project.involved &&
              <div
                className='featured-mission__project__interest featured-mission__project__interest'
                onClick={() => { this.removeProjectRole(project.id) }}
              >
                Unfollow
              </div>
            }
            {!project.involved &&
              <div
                className='featured-mission__project__interest'
                onClick={() => { this.addProjectRole(project.id) }}
              >
                Follow
              </div>
            }
          </div>)}
          <a href={`/projects/new${this.props.id ? `?mission_id=${this.props.id}` : ''}`} className='featured-mission__create-project'>Create New Project</a>
        </div>
      </div>
    )
  }
}

FeaturedMission.propTypes = {
  float      : PropTypes.string,
  id         : PropTypes.number,
  name       : PropTypes.string,
  description: PropTypes.string,
  imageUrl   : PropTypes.string,
  projects   : PropTypes.array,
  csrfToken  : PropTypes.string,
  missionUrl : PropTypes.string
}

FeaturedMission.defaultProps = {
  float      : 'left',
  id         : undefined,
  name       : '',
  description: '',
  imageUrl   : '',
  projects   : [],
  csrfToken  : '00',
  missionUrl : ''
}
