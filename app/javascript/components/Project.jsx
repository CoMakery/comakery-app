import React from 'react'
import PropTypes from 'prop-types'
import Icon from '../components/styleguide/Icon'
import ProfileModal from '../components/ProfileModal'
import MyTask from './MyTask'
import Pluralize from 'react-pluralize'
import d3 from 'd3/d3'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import styled from 'styled-components'

const Tasks = styled.div`
  padding: 15px;
  max-width: 980px;
  margin: auto;
`

const TasksTitle = styled.div`
  margin: 40px;

  h2 {
    font-family: Montserrat;
    font-size: 24px;
    font-weight: 900;
    font-style: normal;
    font-stretch: normal;
    line-height: normal;
    letter-spacing: normal;
    text-align: center;
    text-transform: uppercase;
    color: #3a3a3a;
  }

  p {
    font-family: Georgia;
    font-size: 16px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.63;
    letter-spacing: normal;
    text-align: center;
    color: #4a4a4a;
  }
`

const TasksSpecialty = styled.div`
  margin-top: 40px;

  h3 {
    font-family: Montserrat;
    font-size: 20px;
    font-weight: 900;
    font-style: normal;
    font-stretch: normal;
    line-height: normal;
    letter-spacing: normal;
    text-align: center;
    color: #4a4a4a;
    text-transform: uppercase;

    img {
      display: block;
      margin: auto;
      margin-bottom: 10px;
      max-height: 30px;
      max-width: 30px;
    }
  }
`

const AllTasks = styled.a`
  font-family: Montserrat;
  font-size: 14px;
  font-weight: 900;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-transform: uppercase;
  text-decoration: none;
  color: #0089f4;
  display: block;
  text-align: right;
  margin-top: 60px;
  margin-bottom: 10px;

  &:hover {
    text-decoration: underline;
  }
`

const chartColors = [
  '#0089F4',
  '#24ADFF',
  '#36BFFF',
  '#47D0FF',
  '#FB40E5',
  '#FF64FF',
  '#FF76FF',
  '#FF87FF',
  '#5037F7',
  '#745BFF',
  '#866DFF',
  '#977EFF'
]

export default class Project extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      interested         : props.interested,
      specialtyInterested: [ ...props.specialtyInterested ]
    }

    this.arcTween = this.arcTween.bind(this)
    this.drawChart = this.drawChart.bind(this)
  }

  componentDidMount() {
    // draw piecharts
    const { chartData } = this.props.projectData
    if (chartData && chartData.length > 0) {
      this.drawChart()
    }
  }

  drawChart() {
    const { chartData } = this.props.projectData
    const sum = chartData.reduce((sub, ele) => sub + ele, 0)
    let data = chartData.map((ele, index) => ({ index: index, value: sum > 0 ? (ele / sum * 100).toFixed(2) : 0 }))

    let width = 255
    let height = 255

    let outerRadius = height / 2 - 10
    let innerRadius = outerRadius / 3

    let pie = d3.layout.pie()
      .value((d) => { return d.value })
      .padAngle(0.02)

    let arc = d3.svg.arc()
      .padRadius(outerRadius)
      .innerRadius(innerRadius)

    let svg = d3.select('.project-chart').append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('class', 'project-chart__svg')
      .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')

    let centerEle = svg.append('text')
      .attr('x', 0)
      .attr('y', 5)
      .attr('font-family', 'Montserrat, sans-serif')
      .attr('font-weight', 'bold')
      .attr('font-size', 18)
      .attr('fill', '#3a3a3a')
      .attr('text-anchor', 'middle')

    svg.selectAll('path')
      .data(pie(data.slice(0, 12)))
      .enter().append('path')
      .style('fill', (d, i) => {
        return chartColors[i]
      })
      .each((d) => { d.outerRadius = outerRadius - 10 })
      .attr('d', arc)
      .on('mouseover', this.arcTween(arc, centerEle, outerRadius, 0, true))
      .on('mouseout', this.arcTween(arc, centerEle, outerRadius - 10, 150, false))
  }

  arcTween(arc, centerEle, outerRadius, delay, changeText) {
    const contributors = this.props.projectData.contributors
    return function(d) {
      const { layerX, layerY } = d3.event
      if (changeText) {
        centerEle.text(d.value + '%')
        d3.select('#tooltip')
          .style('left', layerX + 'px')
          .style('top', layerY + 'px')
          .style('opacity', 1)
          .select('#value')
          .text(contributors[d.data.index].nickname || `${contributors[d.data.index].firstName || ''} ${contributors[d.data.index].lastName || ''}`)
      } else {
        d3.select('#tooltip')
          .style('opacity', 0)
        centerEle.text('')
      }
      d3.select(this).transition().delay(delay).attrTween('d', (d) => {
        const i = d3.interpolate(d.outerRadius, outerRadius)
        return function(t) { d.outerRadius = i(t); return arc(d) }
      })
    }
  }

  addInterest(projectId, specialtyId = null) { // protocol = mission name
    const { missionData } = this.props
    const { specialtyInterested } = this.state
    fetchPolyfill('/add-interest', {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        'project_id'        : projectId,
        'specialty_id'      : specialtyId,
        'protocol'          : (missionData ? missionData.name : null),
        'authenticity_token': this.props.csrfToken
      }),
      headers: {
        'Accept'      : 'application/json',
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        if (specialtyId) {
          const newSpecialtyInterested = [...specialtyInterested]
          newSpecialtyInterested[specialtyId - 1] = true
          this.setState({ specialtyInterested: [...newSpecialtyInterested] })
        } else {
          this.setState({ interested: true })
        }
      } else if (response.status === 401) {
        window.location = '/accounts/new'
      } else {
        throw Error(response.text())
      }
    })
  }

  render() {
    const { projectData, missionData, tokenData, contributorsPath, awardsPath, awardTypesPath, editable } = this.props
    const { interested, specialtyInterested } = this.state
    const skills = {
      development: 'Software Development',
      design     : 'UX / UI DESIGN',
      research   : 'Research',
      community  : 'COMMUNITY MANAGEMENT',
      data       : 'DATA GATHERING',
      audio      : 'AUDIO & VIDEO PRODUCTION',
      writing    : 'WRITING',
      marketing  : 'MARKETING & SOCIAL MEDIA'
    }
    const skillIds = [5, 6, 8, 2, 3, 1, 7, 4]

    return <div className="project-container">
      <div className="project-header" style={{backgroundImage: `url(${projectData.panoramicImageUrl})`}}>
        <div className="project-header__blur" />
        <div className="project-header__content">
          <div className="project-header__menu">
            {missionData &&
              <a className="project-header__menu__back" href={missionData.missionUrl}>
                <Icon name="iconBackWhite.svg" style={{marginRight: 8}} />
                {missionData.name}
              </a>
            }

            <div className="project-header__menu__links">
              {projectData.showContributions &&
                <React.Fragment>
                  <a className="project-header__menu__link project-header__menu__link--first" href={contributorsPath}>Contributors</a>
                  <a className="project-header__menu__link" href={awardsPath}>Payments</a>
                </React.Fragment>
              }
              {editable &&
                <a className="project-header__menu__link" href={awardTypesPath}>Edit This Project</a>
              }
              {!editable &&
                <a className="project-header__menu__link" href={awardTypesPath}>BATCHES & TASKS</a>
              }
            </div>
          </div>

          {missionData &&
            <div className="project-header__mission-image">
              <a href={missionData.missionUrl}>
                <img src={missionData.logoUrl} />
              </a>
            </div>
          }

          <div className="project-header__name"> {projectData.title} </div>
          <div className="project-header__owner"> by {projectData.owner} </div>
        </div>
      </div>

      <div className="project-award">
        {tokenData &&
          <div className="project-award__token">
            <div className="project-award__token__left">
              <img className="project-award__token__img" src={tokenData.imageUrl} />
              {tokenData.name} ({tokenData.symbol})
            </div>
            {tokenData.contractUrl &&
              <div className="project-award__token__type">
                {tokenData.coinType}
                <div className="project-award__token__address">
                  <Icon name="iconLink.svg" style={{width: 18, marginRight: 6}} />
                  <a target="_blank" className="project-award__token__address__link" href={tokenData.contractUrl}>Smart Contract</a>
                </div>
              </div>
            }
          </div>
        }

        {tokenData && projectData.awardedTokens > 0 &&
          <div className="project-award__progress">
            <div className="project-award__progress__stats">
              Tokens awarded
              {projectData.maximumTokens &&
                <div>
                  <strong className="project-award__percent">{projectData.tokenPercentage}</strong> - {projectData.awardedTokens} out of {projectData.maximumTokens} {tokenData.symbol}
                </div>
              }
              {!projectData.maximumTokens &&
                <div>
                  {projectData.awardedTokens} {tokenData.symbol}
                </div>
              }
            </div>
            {projectData.maximumTokens &&
              <div className="project-award__progress__bar-container">
                <div className="project-award__progress__bar-line" />
                <div className="project-award__progress__bar-gradient" style={{width: `${projectData.tokenPercentage}`}} />
              </div>
            }
          </div>
        }

        <div className="project-contributors">
          <div className="project-leader">
            <div className="project-leader__info">
              <div className="project-leader__title">Team Leader</div>
              {projectData.teamLeader.firstName} {projectData.teamLeader.lastName}
            </div>
          </div>
          <div className="project-contributors__container">
            <div className="project-contributor-container">
              <img className="project-leader__avatar" src={projectData.teamLeader.imageUrl} />
              <div className="project-contributor__modal">
                <ProfileModal profile={projectData.teamLeader} />
              </div>
            </div>

            {projectData.contributors.map((contributor, index) =>
              <div key={contributor.id} className="project-contributor-container">
                <img className="project-contributor__avatar" style={{zIndex: 5 - index}} src={contributor.imageUrl} />
                <div className="project-contributor__modal">
                  <ProfileModal profile={contributor} />
                </div>
              </div>
            )}
          </div>
          {projectData.contributorsNumber > 5 && <div className="project-contributors__more">+{projectData.contributorsNumber - 5}</div>}
        </div>
      </div>

      <div className="project-description">
        <div className="project-description__video">
          {projectData.videoId &&
            <iframe className="project-description__video__iframe" src={`//www.youtube.com/embed/${projectData.videoId}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0`} frameBorder="0" />
          }
          {!projectData.videoId &&
            <img src={projectData.squareImageUrl} width="100%" />
          }
        </div>
        <div className="project-description__text">
          <div className="project-description__text--first">{projectData.descriptionHeader}.</div>
          <div dangerouslySetInnerHTML={{__html: projectData.descriptionHtml}} />
        </div>
      </div>

      <div className="project-interest">
        <div className="project-stats__container">
          <div className="mission-stats__kpis">
            <div className="mission-stats__kpi">
              <Icon name="BATCH/WHITE.svg" />
              <Pluralize singular="batch" plural="batches" count={projectData.stats.batches} />
            </div>

            <div className="mission-stats__kpi">
              <Icon name="TASK/WHITE.svg" />
              <Pluralize singular="task" count={projectData.stats.tasks} />
            </div>

            <div className="mission-stats__kpi">
              <div className="mission-stats__contributor" />
              <Pluralize singular="person" plural="people" count={projectData.stats.interests} />&nbsp;INTERESTED
            </div>
          </div>
        </div>

        <p className="project-interest__text">Let the project leaders know that you are interested in the project so they can invite you to tasks that you are qualified for.</p>

        {!interested && <button className="button project-interest__button" onClick={() => this.addInterest(projectData.id)}>I’m Interested</button>}
        {interested && <button className="button project-interest__button" disabled>Request Sent</button>}
      </div>

      {this.props.tasksBySpecialty.length > 0 &&
        <Tasks>
          <TasksTitle>
            <h2>Available Tasks</h2>
            <p>Find a task that’s right for your talents, review the details, and get to work!</p>
          </TasksTitle>

          {this.props.tasksBySpecialty.map(specialty =>
            <TasksSpecialty key={specialty[0]}>
              <h3>
                <img src={require(`src/images/specialties/${specialty[0]}.svg`)} />
                {specialty[0]}
              </h3>

              {specialty[1].map(task =>
                <MyTask
                  key={task.id}
                  task={task}
                  displayParents={false}
                />
              )}
            </TasksSpecialty>
          )}

          <AllTasks href={this.props.myTasksPath}>see all available tasks</AllTasks>
        </Tasks>
      }

      {this.props.tasksBySpecialty.length === 0 &&
        <div className="project-skills">
          <div className="project-skills__title">SKILLS NEEDED</div>
          <div className="project-skills__subtitle">Take a challenge to demonstrate your skills. You will be invited to complete tasks that match your skill level for this and other projects</div>

          {Object.keys(skills).map((skill, index) =>
            <div key={skill} className="project-skill-container">
              <div className="project-skill__background">
                <img className="project-skill__background__img" src={require(`src/images/project/${skill}.jpg`)} />
                <div className="project-skill__background__title">
                  {skills[skill]}
                  <div className="project-skill__background__icon">
                    <img className="skill-icon--background" src={require(`src/images/project/background.svg`)} />
                    <img className="skill-icon" src={require(`src/images/project/${skill}.svg`)} />
                  </div>
                </div>
              </div>
              <div className="project-skill__interest">
                {!specialtyInterested[skillIds[index] - 1] && <div className="project-skill__interest__button" onClick={() => this.addInterest(projectData.id, skillIds[index])}>I'm Interested</div>}
                {specialtyInterested[skillIds[index] - 1] && <div className="project-skill__interest__button">Request Sent</div>}
              </div>
            </div>
          )}
        </div>
      }

      <div className="project-team">
        <div className="project-team__container">
          <div className="project-team__title">The Team</div>
          <div className="project-team__subtitle">Great projects are the result of dozens to hundreds of individual tasks being completed with skill and care. Check out the people that have made this project special with their individual contributions.</div>

          <div className="project-chart">
            <div id="tooltip" className="tooltip-hidden">
              <span id="value">100</span>
            </div>
          </div>

          <div className="project-team__contributors-container">
            <div className="project-team__leader-name">Team Leader</div>
            {projectData.teamLeader.firstName} {projectData.teamLeader.lastName}

            <div className="project-team__contributors" >
              <div className="project-team__contributor-container">
                <img className="project-team__leader-avatar" src={projectData.teamLeader.imageUrl} />
                <div className="project-team__contributor__modal">
                  <ProfileModal profile={projectData.teamLeader} />
                </div>
              </div>

              {projectData.contributors.map((contributor, index) =>
                <div key={contributor.id} className="project-team__contributor-container">
                  <img className="project-team__contributor__avatar" style={{zIndex: 5 - index}} src={contributor.imageUrl} />
                  <div className="project-team__contributor__modal">
                    <ProfileModal profile={contributor} />
                  </div>
                </div>
              )}
            </div>
            {projectData.contributorsNumber > 5 && <div className="project-team__contributors__more">+{projectData.contributorsNumber - 5}</div>}
          </div>
        </div>
      </div>

      <div className="project-interest">
        <p className="project-interest__text">Let the project leaders know that you are interested in the project so they can invite you to tasks that you are qualified for.</p>
        {!interested && <button className="button project-interest__button" onClick={() => this.addInterest(projectData.id)}>I’m Interested</button>}
        {interested && <button className="button project-interest__button" disabled>Request Sent</button>}
      </div>
    </div>
  }
}

Project.propTypes = {
  tasksBySpecialty: PropTypes.array,
  projectData     : PropTypes.shape({}),
  missionData     : PropTypes.shape({}),
  tokenData       : PropTypes.shape({}),
  interested      : PropTypes.bool,
  csrfToken       : PropTypes.string,
  editable        : PropTypes.bool,
  contributorsPath: PropTypes.string,
  awardsPath      : PropTypes.string,
  awardTypesPath  : PropTypes.string,
  myTasksPath     : PropTypes.string,
  editPath        : PropTypes.string
}

Project.defaultProps = {
  tasksBySpecialty: [ [ null, [] ] ],
  projectData     : {
    description : '',
    teamLeader  : {},
    contributors: [],
    chartData   : [],
    stats       : {}
  },
  missionData        : null,
  tokenData          : null,
  interested         : false,
  specialtyInterested: [],
  csrfToken          : '',
  editable           : true,
  contributorsPath   : '',
  awardsPath         : '',
  awardTypesPath     : '',
  myTasksPath        : '',
  editPath           : null
}
