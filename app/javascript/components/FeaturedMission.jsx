import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'

export default class FeaturedMission extends React.Component {
  constructor(props) {
    super(props)

    this.addInterest = this.addInterest.bind(this)
    this.state = {
      name       : props.name,
      description: props.description,
      imageUrl   : props.imageUrl,
      projects   : props.projects
    }
  }

  addInterest(projectId) { // protocol = mission name
    fetchPolyfill('/add-interest', {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({'project_id': projectId, 'protocol': this.props.name, 'authenticity_token': this.props.csrfToken}),
      headers    : {
        'Accept'      : 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(response => {
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

  render() {
    const { name, description, imageUrl, projects } = this.state

    return (
      <div className={`featured-mission ${this.props.float === 'right' ? 'featured-mission--right' : ''}`}>
        <div className={`featured-mission__image ${this.props.float === 'right' ? 'featured-mission__image--right' : ''}`}>
          <img src={imageUrl} />
        </div>
        <div className="featured-mission__detail">
          <div className="featured-mission__name">{name}</div>
          <div className="featured-mission__description">{description}</div>
          {projects.map(project => <div key={project.id} className="featured-mission__project">
            <a href={`/projects/${project.id}`} className="featured-mission__project__title">{project.title}</a>
            {project.interested && <div className="featured-mission__project__interest featured-mission__project__interest--sent">Request Sent</div>}
            {!project.interested &&
            <div className="featured-mission__project__interest" onClick={() => { this.addInterest(project.id) }}>I’m interested</div>
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
  csrfToken  : PropTypes.string
}

FeaturedMission.defaultProps = {
  float      : 'left',
  id         : undefined,
  name       : '',
  description: '',
  imageUrl   : '',
  projects   : [],
  csrfToken  : '00'
}
