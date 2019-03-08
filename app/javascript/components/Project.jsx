import React from 'react'
import PropTypes from 'prop-types'
import Icon from '../components/styleguide/Icon'
import d3 from 'd3/d3'

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
      interested: props.interested
    }

    this.arcTween = this.arcTween.bind(this)
    this.drawChart = this.drawChart.bind(this)
  }

  componentDidMount() {
    // draw piecharts
    this.drawChart()
  }

  drawChart() {
    let data = [89, 34, 56, 18, 200]

    let width = 255
    let height = 255

    let outerRadius = height / 2 - 10
    let innerRadius = outerRadius / 3

    let pie = d3.layout.pie()
      .padAngle(0.02)

    let arc = d3.svg.arc()
      .padRadius(outerRadius)
      .innerRadius(innerRadius)

    let svg = d3.select('.project-chart').append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
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
      .data(pie(data))
      .enter().append('path')
      .style('fill', (d) => {
        return '#3f4eff'
      })
      .each((d) => { d.outerRadius = outerRadius - 10 })
      .attr('d', arc)
      .on('mouseover', this.arcTween(arc, centerEle, outerRadius, 0, true))
      .on('mouseout', this.arcTween(arc, centerEle, outerRadius - 10, 150, false))
  }

  arcTween(arc, centerEle, outerRadius, delay, changeText) {
    return function() {
      d3.select(this).transition().delay(delay).attrTween('d', (d) => {
        const i = d3.interpolate(d.outerRadius, outerRadius)
        if (changeText) {
          centerEle.text(d.value + '%')
        }
        return function(t) { d.outerRadius = i(t); return arc(d) }
      })
    }
  }

  render() {
    const { projectData, missionData, tokenData } = this.props
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

    return <div className="project-container">
      <div className="project-header" style={{backgroundImage: projectData.imageUrl}}>
        <div className="project-header__blur" />
        <div className="project-header__content">
          <div className="project-header__menu">
            <div className="project-header__menu__back">
              <Icon name="iconBackWhite.svg" style={{marginRight: 8}} />
              {missionData.name}
            </div>

            <div className="project-header__menu__links">
              <div className="project-header__menu__link">Contributors</div>
              <div className="project-header__menu__link">Payments</div>
              <div className="project-header__menu__link project-header__menu__link--last">Edit This Project</div>
            </div>
          </div>

          <div className="project-header__mission-image">
            <img src={missionData.imageUrl} />
          </div>

          <div className="project-header__name"> {projectData.title} </div>
          <div className="project-header__owner"> by {projectData.owner} </div>
        </div>
      </div>

      <div className="project-award">
        <div className="project-award__token">
          <img className="project-award__token__img" src={tokenData.imageUrl} />
          {tokenData.name} ({tokenData.symbol})
          <div className="project-award__token__type">
            {tokenData.coinType}
            {tokenData.contractUrl &&
              <div className="project-award__token__address">
                <Icon name="iconLink.svg" style={{width: 18, marginRight: 6}} />
                <a href={tokenData.contractUrl}>Smart Contract</a>
              </div>
            }
          </div>
        </div>

        <div className="project-award__progress">
          <div className="project-award__progress__stats">
            Tokens awarded
            <div><strong className="project-award__percent">{projectData.tokenPercentage}%</strong> - {projectData.awardedTokens} out of {projectData.maximumTokens} {tokenData.symbol}</div>
          </div>
          <div className="project-award__progress__bar-container">
            <div className="project-award__progress__bar-line" />
            <div className="project-award__progress__bar-gradient" style={{width: `${projectData.tokenPercentage}%`}} />
          </div>
        </div>

        <div className="project-contributors">
          <div className="project-leader">
            <div className="project-leader__info">
              <div className="project-leader__title">Team Leader</div>
              {projectData.teamLeader.firstName} {projectData.teamLeader.lastName}
            </div>
            <img className="project-leader__avatar" src={projectData.teamLeader.imageUrl} />
          </div>

          {projectData.contributors.map((contributor, index) =>
            <div key={contributor.id} className="project-contributor-container">
              <img className="project-contributor__avatar" style={{zIndex: 5 - index}} src={contributor.imageUrl} />
              <div className="project-contributor__modal">Test</div>
            </div>
          )}
          {projectData.contributorsNumber > 5 && <div className="project-contributors__more">+{projectData.contributorsNumber - 5}</div>}
        </div>
      </div>

      <div className="project-description">
        <div className="project-description__video">
          {!projectData.youtubeUrl && <img src={projectData.defaultImageUrl} width="100%" />}
          {projectData.youtubeUrl &&
            <iframe width="100%" height="304" src={`//www.youtube.com/embed/${projectData.youtubeUrl}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0`} frameBorder="0" />
          }
        </div>
        <div className="project-description__text">Test</div>
      </div>

      <div className="project-interest">
        <button className="project-interest__button">I’m Interested</button>
        <p className="project-interest__text">Let the project leaders know that you are interested in the project so they can invite you to tasks that you are qualified for.</p>
      </div>

      <div className="project-skills">
        <div className="project-skills__title">SKILLS NEEDED</div>
        <div className="project-skills__subtitle">Take a challenge to demonstrate your skills. You will be invited to complete tasks that match your skill level for this and other projects</div>
        {Object.keys(skills).map(skill =>
          <div key={skill} className="project-skill-container">
            <div className="project-skill__background">
              <img className="project-skill__background__img" src={require(`src/images/project/${skill}.jpg`)} />
              <div className="project-skill__background__title">
                {skills[skill]}
                <div className="project-skill__background__icon">
                  <img className="skill-icon--background" src={require(`src/images/project/background.svg`)} />
                  <img className="skill-icon" width="45" height="45" src={require(`src/images/project/${skill}.svg`)} />
                </div>
              </div>
            </div>

            <div className="project-skill__interest">
              <div className="project-skill__interest__button">I'm Interested</div>
            </div>
          </div>
        )}
      </div>
      <div className="project-interest">
        <button className="project-interest__button">I’m Interested</button>
        <p className="project-interest__text">Let the project leaders know that you are interested in the project so they can invite you to tasks that you are qualified for.</p>
      </div>

      <div className="project-team">
        <div className="project-team__title">The Team</div>
        <div className="project-team__subtitle">Great projects are the result dozens to hundreds of individual tasks being completed with skill and care. Check out the people that have made this project special with their individual contributions.</div>
        <div className="project-chart" />
      </div>
    </div>
  }
}

Project.propTypes = {
  projectData: PropTypes.shape({}),
  missionData: PropTypes.shape({}),
  tokenData  : PropTypes.shape({}),
  interested : PropTypes.bool
}

Project.defaultProps = {
  projectData: {},
  missionData: {},
  tokenData  : {},
  interested : false
}
