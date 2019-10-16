import React from 'react'
import PropTypes from 'prop-types'
import Icon from '../components/styleguide/Icon'
import ProfileModal from '../components/ProfileModal'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import Pluralize from 'react-pluralize'

export default class Mission extends React.Component {
  constructor(props) {
    super(props)
    this.addInterest = this.addInterest.bind(this)

    const interests = {}
    props.projects.forEach(project => {
      if (project.projectData) {
        interests[project.projectData.id] = project.interested
      }
    })
    this.state = { interests }
  }

  addInterest(projectId, specialtyId = null) { // protocol = mission name
    const { mission } = this.props

    fetchPolyfill('/add-interest', {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        'project_id'        : projectId,
        'specialty_id'      : specialtyId,
        'protocol'          : (mission ? mission.name : null),
        'authenticity_token': this.props.csrfToken
      }),
      headers: {
        'Accept'      : 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        return response.json()
      } else if (response.status === 401) {
        window.location = '/accounts/new'
      } else {
        throw Error(response.text())
      }
    }).then(response => {
      this.setState({ interests: {...this.state.interests, [response.projectId]: true} })
    })
  }

  render() {
    const { mission, leaders, tokens, projects, newProjectUrl } = this.props
    const { interests } = this.state

    return <div className="mission-container">
      <div className="mission-header">
        <div className="mission-header__blur" style={{backgroundImage: `url(${mission.imageUrl})`}} />
        <div className="mission-header__logo">
          <img className="mission-header__logo__img" src={mission.logoUrl} />
        </div>
        <a className="mission-header__link" href={newProjectUrl}>CREATE A PROJECT</a>
      </div>

      <div className="mission-details">
        <div className="mission-details__heading">Mission</div>
        <div className="mission-details__name">{mission.name}</div>
        <div className="mission-details__subtitle">{mission.subtitle}</div>
        <div className="mission-details__description">{mission.description}</div>
      </div>

      <div className="mission-leaders">
        Featured Project Leaders
        <div className="mission-leaders__wrapper">
          {leaders.map(leader => <div key={leader.id} className="mission-leaders__individual">
            {leader.imageUrl && <img src={leader.imageUrl} />}
            <div className="mission-leaders__individual__blur" />
            <div className="mission-leaders__individual__info">
              <div className="mission-leaders__individual__info__name">
                {leader.firstName} {leader.lastName}
              </div>
              <div className="mission-leaders__individual__info__associate">Associated with</div>
              <Pluralize singular="project" count={leader.count} />
            </div>
          </div>)}

          <div className="mission-leaders__own">
            Want to be a project leader for this mission?
            <a className="mission-leaders__own__create" href={newProjectUrl}>CREATE YOUR OWN PROJECT</a>
          </div>
        </div>
      </div>

      <div className="mission-tokens">
        Tokens Used In The Mission
        <div className="mission-tokens__cards">
          {tokens.tokens.map(token => <div key={token.id} className="mission-tokens__card">
            {token.contractUrl && <a href={token.contractUrl} className="mission-tokens__card__header__link">
              <Icon name="iconLink.svg" />
            </a>}
            <div className="mission-tokens__card__header">
              <img className="mission-tokens__card__header__logo" src={token.logoUrl} />
              <div className="mission-tokens__card__header__name">
                {token.name} ({token.symbol})
              </div>
            </div>

            <div className="mission-tokens__card__info">
              <div className="mission-tokens__card__info__associate">Associated with</div>
              <Pluralize singular="project" count={token.count} />
            </div>
          </div>)}

          {tokens.tokenCount > 4 && <div className="mission-tokens__more">+{tokens.tokenCount - 4} more</div>}
        </div>

      </div>

      <div className="mission-stats">
        <div className="mission-stats__heading">Mission Stats</div>

        <div className="mission-stats__container">
          <div className="mission-stats__kpis">

            <div className="mission-stats__kpi">
              <Icon name="PROJECT/WHITE.svg" />
              <Pluralize singular="project" count={mission.stats.projects} />
            </div>

            <div className="mission-stats__kpi">
              <Icon name="BATCH/WHITE.svg" />
              <Pluralize singular="batch" plural="batches" count={mission.stats.batches} />
            </div>

            <div className="mission-stats__kpi">
              <Icon name="TASK/WHITE.svg" />
              <Pluralize singular="task" count={mission.stats.tasks} />
            </div>

            <div className="mission-stats__kpi">
              <div className="mission-stats__contributor" />
              <Pluralize singular="person" plural="people" count={mission.stats.interests} />&nbsp;INTERESTED
            </div>

          </div>
        </div>
      </div>

      <div className="mission-projects">
        <div className="mission-projects__container">
          <div className="mission-projects__heading">Featured Projects</div>

          {projects.map(project => <div key={project.projectData.id} className="mission-projects__single">
            <div className="mission-projects__single__header">
              {project.tokenData && <div className="mission-projects__single__token">
                Paid in&nbsp;
                <span className="mission-projects__single__token__name">{project.tokenData.name}</span>
                <img src={project.tokenData.logoUrl} />
              </div>}

              <div className="mission-projects__single__title-wrapper">
                <div className="mission-projects__single__title">
                  <a href={project.projectUrl} className="mission-projects__single__title__heading">{project.projectData.title}</a>
                </div>

                <div className="mission-projects__single__contributors">
                  <div className="project-team">
                    <div className="project-team__container">
                      <div className="project-team__contributors-container">
                        <div className="project-team__contributors" >
                          {project.projectData.team && project.projectData.team.map((contributor, index) =>
                            <div key={contributor.id} className="project-team__contributor-container">
                              <img className={(contributor.specialty && contributor.specialty.name === 'Team Leader') ? 'project-team__contributor__avatar--team-leader' : 'project-team__contributor__avatar'} style={{zIndex: 15 - index}} src={contributor.imageUrl} />
                              <div className="project-team__contributor__modal">
                                <ProfileModal profile={contributor} />
                              </div>
                            </div>
                          )}
                        </div>
                        {project.projectData.teamSize > 15 && <div className="project-team__contributors__more">+{project.projectData.teamSize - 15}</div>}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="mission-projects__single__card">
              <div className="mission-projects__single__desktop">
                <a href={project.projectUrl} className="mission-projects__single__card__img">
                  <img src={project.projectData.squareUrl || project.projectData.defaultImageUrl} />
                  <Icon className="mission-projects__single__card__img__mask" name="PROJECT/MASK.svg" />
                </a>

                <div className="mission-column__wrapper">
                  <div className="mission-projects__single__card__info">
                    <span className="mission-projects__single__description--desktop">{project.projectData.description}</span>
                    <div className="mission-projects__single__card__info__stats">

                      <div className="mission-projects__single__card__info__row">
                        <Pluralize singular="interested" plural="interested" count={project.stats.interests} />
                        <Icon name="circleGray.svg" />
                      </div>

                      <div className="mission-projects__single__card__info__row">
                        <Pluralize singular="batch" plural="batches" count={project.stats.batches} />
                        <Icon name="BATCH/GREY.svg" />
                      </div>

                      <div className="mission-projects__single__card__info__row">
                        <Pluralize singular="task" count={project.stats.tasks} />
                        <Icon name="TASK/GRAY.svg" />
                      </div>

                    </div>
                  </div>

                  <div className="mission-projects__single__card__info__interest">
                    {project.editable && <a className="mission-projects__single__card__info__interest__link" href={`/projects/${project.projectData.id}/edit`}>EDIT PROJECT</a>}
                    {!project.editable && interests[project.projectData.id] && <div className="mission-projects__single__card__info__interest__link" style={{opacity: 0.2}}>Request sent</div>}
                    {!project.editable && !interests[project.projectData.id] &&
                    <div
                      className="mission-projects__single__card__info__interest__link"
                      onClick={() => { this.addInterest(project.projectData.id) }}
                    >I'M INTERESTED</div>
                    }
                    <a className="mission-projects__single__card__info__interest__link" href={`/projects/${project.projectData.id}`}>See details</a>
                  </div>
                </div>
              </div>

              <div className="mission-projects__single__mobile">
                {project.projectData.description}
                <div className="mission-projects__single__card__info__interest mission-projects__single__card__info__interest--mobile">
                  {project.editable && <a className="mission-projects__single__card__info__interest__link" href={`/projects/${project.projectData.id}/edit`}>EDIT PROJECT</a>}
                  {!project.editable && interests[project.projectData.id] && <div className="mission-projects__single__card__info__interest__link" style={{opacity: 0.2}}>Request sent</div>}
                  {!project.editable && !interests[project.projectData.id] &&
                    <div
                      className="mission-projects__single__card__info__interest__link"
                      onClick={() => { this.addInterest(project.projectData.id) }}
                    >I'M INTERESTED</div>
                  }
                  <a className="mission-projects__single__card__info__interest__link" href={`/projects/${project.projectData.id}`}>See details</a>
                </div>
              </div>
            </div>
          </div>)}
        </div>
      </div>
    </div>
  }
}

Mission.propTypes = {
  mission : PropTypes.shape({}),
  projects: PropTypes.array,
  leaders : PropTypes.array,
  tokens  : PropTypes.shape({}),
}

Mission.defaultProps = {
  mission : { stats: {} },
  projects: [],
  leaders : [],
  tokens  : { tokens: [] },
}
