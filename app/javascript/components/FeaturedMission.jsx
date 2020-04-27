import React from 'react'
import PropTypes from 'prop-types'
import InterestsController from '../controllers/interests_controller'

export default class FeaturedMission extends React.Component {
  constructor(props) {
    super(props)

    this.addInterest = this.addInterest.bind(this)
    this.removeInterest = this.removeInterest.bind(this)
    this.state = {
      name       : props.name,
      description: props.description,
      imageUrl   : props.imageUrl,
      projects   : props.projects
    }
  }

  addInterest(projectId) {
    new InterestsController().follow(projectId).then(response => {
      if (response.status === 200) {
        let newProjects = Array.from(this.state.projects)
        const index = newProjects.findIndex(project => project.id === projectId)
        newProjects[index].interested = true
        this.setState({projects: newProjects})
      } if (response.status === 401) {
        window.location = '/accounts/new'
      } else {
        throw Error(response.text())
      }
    })
  }

  removeInterest(projectId) {
    new InterestsController().unfollow(projectId).then(response => {
      if (response.status === 200) {
        let newProjects = Array.from(this.state.projects)
        const index = newProjects.findIndex(project => project.id === projectId)
        newProjects[index].interested = false
        this.setState({projects: newProjects})
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
        <div className="featured-mission__detail">
          <div className="featured-mission__name">
            <a href={missionUrl}>{name}</a>
          </div>
          <div className="featured-mission__description">{description}</div>
          {projects.map(project => <div key={project.id} className="featured-mission__project">
            <a href={`/projects/${project.id}`} className="featured-mission__project__title">{project.title}</a>
            {project.interested &&
              <div
                className="featured-mission__project__interest featured-mission__project__interest"
                onClick={() => { this.removeInterest(project.id) }}
              >
                Unfollow
              </div>
            }
            {!project.interested &&
              <div
                className="featured-mission__project__interest"
                onClick={() => { this.addInterest(project.id) }}
              >
                Follow
              </div>
            }
          </div>)}
          <a href={`/projects/new${this.props.id ? `?mission_id=${this.props.id}` : ''}`} className="featured-mission__create-project">Create New Project</a>
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
