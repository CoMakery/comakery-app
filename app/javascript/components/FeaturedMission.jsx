import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'

export default class FeaturedMission extends React.Component {
  constructor(props) {
    super(props)

    this.addInterest = this.addInterest.bind(this)
    this.state = {
      name       : props.name,
      symbol     : props.symbol,
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
        // need to update project
        let newProjects = Array.from(this.state.projects)
        const index = newProjects.findIndex(project => project.id === projectId)

        newProjects[index].interested = true

        this.setState({projects: newProjects})
      } else {
        throw Error(response.text())
      }
    })
  }

  render() {
    const { name, symbol, description, imageUrl, projects } = this.state

    return (
      <div className={`featured-mission ${this.props.float === 'right' ? 'featured-mission--right' : ''}`}>
        <div className={`featured-mission__image ${this.props.float === 'right' ? 'featured-mission__image--right' : ''}`}>
          <img src={imageUrl} />
        </div>
        <div className="featured-mission__detail">
          <div className="featured-mission__name">{name} {symbol && `(${symbol})`}</div>
          <div className="featured-mission__description">{description}</div>
          {projects.map(project => <div key={project.id} className="featured-mission__project">
            <div className="featured-mission__project__title">{project.title}</div>
            {project.interested && <div className="featured-mission__project__interest featured-mission__project__interest--sent">Request Sent</div>}
            {!project.interested &&
            <div className="featured-mission__project__interest" onClick={() => { this.addInterest(project.id) }}>I’m interested</div>
            }
          </div>)}
          <div className="featured-mission__create-project">Create New Project</div>
        </div>
      </div>
    )
  }
}

FeaturedMission.propTypes = {
  float      : PropTypes.string,
  name       : PropTypes.string,
  symbol     : PropTypes.string,
  description: PropTypes.string,
  imageUrl   : PropTypes.string,
  projects   : PropTypes.array,
  csrfToken  : PropTypes.string
}

FeaturedMission.defaultProps = {
  float      : 'left',
  name       : '',
  symbol     : '',
  description: '',
  imageUrl   : '',
  projects   : [],
  csrfToken  : '00'
}
