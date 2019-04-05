import React from 'react'
import PropTypes from 'prop-types'
import Icon from '../components/styleguide/Icon'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import Pluralize from 'react-pluralize'

export default class Mission extends React.Component {
  constructor(props) {
    super(props)
    this.addInterest = this.addInterest.bind(this)

    const interests = {}
    props.projects.forEach(project => {
      interests[project.projectData.id] = project.interested
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
    const { mission, leaders, tokens, projects, newProjectUrl, stats } = this.props
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
              {leader.projectName}
              {leader.count > 1 && `, +${leader.count - 1}`}
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
            <div className="mission-tokens__card__header">
              <img className="mission-tokens__card__header__logo" src={token.logoUrl} />
              {token.name} ({token.symbol})
              {token.contractUrl && <a href={token.contractUrl} className="mission-tokens__card__header__link">
                <Icon name="iconLink.svg" style={{width: 18}} />
              </a>}
            </div>

            <div className="mission-tokens__card__info">
              {token.projectName}
              {token.count > 1 && `, +${token.count - 1}`}
            </div>
          </div>)}
        </div>

        {tokens.tokenCount > 4 && <div className="mission-tokens__more">+{tokens.tokenCount - 4} more</div>}
      </div>

      <div className="mission-stats">
        Mission Stats

        <div className="mission-stats__container">
          <div className="mission-stats__kpis">
            <div className="mission-stats__kpis__row">
              <div className="mission-stats__kpi">
                <Icon name="PROJECT/WHITE.svg" />
                <Pluralize singular="project" count={stats.projects} />
              </div>
              <div className="mission-stats__kpi">
                <Icon name="BATCH/WHITE.svg" />
                <Pluralize singular="batch" plural="batches" count={stats.batches} />
              </div>
            </div>

            <div className="mission-stats__kpis__row">
              <div className="mission-stats__kpi">
                <Icon name="TASK/WHITE.svg" />
                <Pluralize singular="task" count={stats.tasks} />
              </div>
              <div className="mission-stats__kpi">
                <div className="mission-stats__contributor" />
                <Pluralize singular="person" count={stats.interests} />&nbsp;INTERESTED
              </div>
            </div>

            <div className="mission-stats__kpi mission-stats__kpi--desktop">
              <Icon name="PROJECT/WHITE.svg" />
              <Pluralize singular="project" count={stats.projects} />
            </div>
            <div className="mission-stats__kpi mission-stats__kpi--desktop">
              <Icon name="BATCH/WHITE.svg" />
              <Pluralize singular="batch" plural="batches" count={stats.batches} />
            </div>

            <div className="mission-stats__kpi mission-stats__kpi--desktop">
              <Icon name="TASK/WHITE.svg" />
              <Pluralize singular="task" count={stats.tasks} />
            </div>
            <div className="mission-stats__kpi mission-stats__kpi--desktop">
              <div className="mission-stats__contributor" />
              <Pluralize singular="person" count={stats.interests} />&nbsp;INTERESTED
            </div>
          </div>
        </div>
      </div>

      <div className="mission-projects">
        <div className="mission-projects__container">
          <div className="mission-projects__heading">Featured Projects</div>

          {projects.map(project => <div key={project.projectData.id} className="mission-projects__single">
            <div className="mission-projects__single__header">
              <div className="mission-projects__single__token">
                <img src={project.tokenData.logoUrl} /> Paid in&nbsp;
                <span className="mission-projects__single__token__name">{project.tokenData.name}</span>
              </div>

              <div className="mission-projects__single__title-wrapper">
                <div className="mission-projects__single__title">
                  <div className="mission-projects__single__title__heading">{project.projectData.title}</div>
                  {project.projectData.title}
                </div>

                <div className="mission-projects__single__contributors">
                  <div className="project-contributors">
                    <div className="project-leader">
                      <div className="project-leader__info">
                        <div className="project-leader__title">Team Leader</div>
                        {project.projectData.teamLeader.firstName} {project.projectData.teamLeader.lastName}
                      </div>
                      <img className="project-leader__avatar" src={project.projectData.teamLeader.imageUrl} />
                    </div>
                    <div className="project-contributors__container">
                      <img className="project-leader__avatar project-leader__avatar--mobile" src={project.projectData.teamLeader.imageUrl} />
                      {project.projectData.contributors.map((contributor, index) =>
                        <div key={contributor.id} className="project-contributor-container project-contributor-container--desktop">
                          <img className="project-contributor__avatar" style={{zIndex: 5 - index}} src={contributor.imageUrl} />
                          <div className="project-contributor__modal">
                            <img className="project-contributor__modal-avatar" src={contributor.imageUrl} />
                            <div className="project-contributor__modal__info">
                              <div className="project-contributor__modal-nickname">{contributor.nickname && contributor.nickname}</div>
                              <div className="project-contributor__modal-name">{contributor.firstName} {contributor.lastName}</div>
                              <div className="project-contributor__modal-specialty">{contributor.specialty}</div>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                    {project.projectData.contributorsNumber > 5 && <div className="project-contributors__more">+{project.projectData.contributorsNumber - 5}</div>}
                    {project.projectData.contributorsNumber > 1 && <div className="project-contributors__more project-contributors__more--mobile">+{project.projectData.contributorsNumber - 1}</div>}
                  </div>
                </div>
              </div>
            </div>

            <div className="mission-projects__single__card">
              <div className="mission-projects__single__desktop">
                <div className="mission-projects__single__card__img">
                  <img style={{width: '100%'}} src={project.projectData.squareUrl || project.projectData.defaultImageUrl} />
                  <Icon className="mission-projects__single__card__img__mask" name="PROJECT/MASK.svg" />
                </div>

                <div className="mission-column__wrapper">
                  <div className="mission-projects__single__card__info">
                    <span className="mission-projects__single__description--desktop">{project.projectData.description}</span>
                    <div className="mission-projects__single__card__info__stats">
                      <div className="mission-projects__single__card__info__row">
                        <Pluralize singular="batch" plural="batches" count={project.batches} />
                        <Icon name="BATCH/GREY.svg" />
                      </div>
                      <div className="mission-projects__single__card__info__row">
                        <Pluralize singular="task" count={project.tasks} />
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
