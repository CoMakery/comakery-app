import React from 'react'
import PropTypes from 'prop-types'
import FeaturedMission from './FeaturedMission'
import Slider from 'react-slick'
import styled from 'styled-components'

import logo from '../src/images/styleguide/icons/Logo-Footer.svg'
import developersImg from '../src/images/featured/developers.png'
import communityManagersImg from '../src/images/featured/community-managers.png'
import chatImg from '../src/images/featured/chat.svg'

const VideoHowItWorks = styled.div`
  flex-grow: 2;

  @media (max-width: 1024px) {
    height: 334px;
    width: 100%;
  }

  @media (max-width: 600px) {
    height: 234px;
    width: 100%;
  }

  iframe {
    width: 100%;
    height: 100%;
    border-radius: 3px;
  }
`

export default class FeaturedMissions extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      topMissions: props.topMissions
    }
  }

  render() {
    const { topMissions } = this.state
    const { moreMissions } = this.props
    const moreMissionsCount = moreMissions.length
    const settings = {
      slidesToShow  : Math.min(4, moreMissionsCount),
      slidesToScroll: 1,
      lazyLoad      : true,
      responsive    : [
        {
          breakpoint: 1440,
          settings  : {
            slidesToShow: Math.min(3, moreMissionsCount)
          }
        },
        {
          breakpoint: 800,
          settings  : {
            slidesToShow: Math.min(2, moreMissionsCount)
          }
        },
        {
          breakpoint: 650,
          settings  : {
            slidesToShow: 1
          }
        }
      ]
    }
    return (
      <div className="featured-missions">
        {!this.props.isConfirmed &&
          <div className="grayed-page" />
        }
        <div className="featured-missions__header">
          {this.props.isConfirmed &&
            <div className="intercom intercom-button">
              <img src={chatImg} />
            </div>
          }
          <div className="featured-missions__header_container">

            <VideoHowItWorks>
              <iframe src="https://player.vimeo.com/video/345071697?byline=0&title=false&portrait=0&color=ffffff" frameBorder="0" allow="autoplay; fullscreen" allowFullScreen />
            </VideoHowItWorks>

            <script async src="https://player.vimeo.com/api/player.js" />

            <div className="featured-missions__header__description">
              <img className="featured-missions__header__logo" src={logo} />
              <div className="featured-missions__header__title">
                Gather a Tribe.<br />
                Achieve Big Missions.
              </div>
              <div className="featured-missions__header__subtitle">Bring people together around a common vision.</div>
            </div>
          </div>
        </div>

        <div className="featured-missions__content">
          <p className="featured-missions__content__title">
              Featured<br />
            <span className="featured-missions__content__title--big">missions</span>
          </p>
          <p className="featured-missions__content__description">CoMakery Hosts Blockchain Missions We Believe In</p>
          {
            topMissions.map((mission, index) =>
              <FeaturedMission
                key={mission.id}
                id={mission.id}
                missionUrl={mission.missionUrl}
                float={index % 2 === 0 ? 'left' : 'right'}
                name={mission.name}
                imageUrl={mission.imageUrl}
                description={mission.description}
                projects={mission.projects}
                csrfToken={this.props.csrfToken}
              />
            )
          }
        </div>
        <div className="featured-missions__more">
          <div className="featured-missions__more_container">
            {/* <p className="featured-missions__more__title">
              40+<br />
              <span className="featured-missions__more__title--big">missions</span>
            </p> */}
            <p className="featured-missions__more__description">Discover Missions With Cutting Edge Projects</p>
            <Slider className="featured-missions__gallery" {...settings}>
              { moreMissions.map((mission) =>
                <div key={mission.id}>
                  <div className="gallery-content">
                    <div className="gallery-content__image">
                      <a href={mission.missionUrl}>
                        <img src={mission.imageUrl} />
                      </a>
                    </div>
                    <div className="gallery-content__title">
                      <a href={mission.missionUrl}>{mission.name}</a>
                    </div>
                    <div className="gallery-content__description">
                      {mission.projectsCount === 0 && 'No projects'}
                      {mission.projectsCount > 0 && `${mission.projectsCount} ${mission.projectsCount === 1 ? 'project' : 'projects'}` }
                    </div>
                  </div>
                </div>
              )}
            </Slider>
          </div>
        </div>
        <div className="featured-missions__footer">
          <div className="featured-missions__footer_container">
            <div className="featured-missions__footer__stat">
              <div className="featured-missions__footer__stat__num">1000+</div>
              <div className="featured-missions__footer__stat__name">Contributors</div>
            </div>
            <img src={communityManagersImg} className="hide-on-mobile" />
            <div className="featured-missions__footer__stat">
              <div className="featured-missions__footer__stat__num">500+</div>
              <div className="featured-missions__footer__stat__name">PROJECTS</div>
            </div>
            <img src={developersImg} className="hide-on-mobile" />
            <div className="featured-missions__footer__stat">
              <div className="featured-missions__footer__stat__num">1,000,000+</div>
              <div className="featured-missions__footer__stat__name">TOKENS AWARDED</div>
            </div>
            <div className="featured-missions__footer__mobile">
              <img src={communityManagersImg} />
              <img src={developersImg} style={{marginLeft: -30}} />
            </div>
          </div>
        </div>
      </div>
    )
  }
}

FeaturedMissions.propTypes = {
  topMissions : PropTypes.array,
  moreMissions: PropTypes.array,
  csrfToken   : PropTypes.string,
  isConfirmed : PropTypes.bool
}

FeaturedMissions.defaultProps = {
  topMissions : [],
  moreMissions: [],
  csrfToken   : '00',
  isConfirmed : false
}
