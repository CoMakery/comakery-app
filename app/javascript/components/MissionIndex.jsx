import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'

export default class MissionIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.state = {
      selectedMission: null
    }
  }

  handleListClick(mission) {
    this.setState({
      selectedMission: mission
    })
  }

  render() {
    return (
      <React.Fragment>
        <Layout
          className="mission-index"
          title="Missions"
          sidebar={
            <React.Fragment>
              <div className="mission-index--sidebar">
                <SidebarItemBold
                  className="mission-index--sidebar--item__bold"
                  iconLeftName="MARK-WHITE.svg"
                  iconRightName="PLUS.svg"
                  text="Create a Mission"
                  onClick={(_) => window.location = '/missions/new'}
                />

                <hr />

                { this.props.missions.length > 0 &&
                  <React.Fragment>
                    <div className="mission-index--sidebar--info">
                      Please select or rearrange missions you want to display on landing page:
                    </div>

                    {this.props.missions.map((t) =>
                      <SidebarItem
                        className="mission-index--sidebar--item"
                        key={t.id}
                        iconLeftUrl={t.logoPreview}
                        iconRightName="REARRANGE.svg"
                        text={t.name}
                        selected={this.state.selectedMission === t}
                        onClick={(_) => this.handleListClick(t)}
                      />
                    )}
                  </React.Fragment>
                }
              </div>
            </React.Fragment>
          }
        >
          {this.state.selectedMission &&
            <div className="mission-index--view">
              <div className="mission-index--view--logo">
                <img
                  src={this.state.selectedMission.imagePreview}
                />
              </div>

              <div className="mission-index--view--info">
                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    name
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {this.state.selectedMission.name}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    token
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {this.state.selectedMission.tokenName}
                    {this.state.selectedMission.tokenSymbol && ` (${this.state.selectedMission.tokenSymbol})`}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    subtitle
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {this.state.selectedMission.subtitle}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    description
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {this.state.selectedMission.description}
                  </div>
                </div>
              </div>

              <div className="mission-index--view--link">
                <a
                  href={`/missions/${this.state.selectedMission.id}/edit`}
                >
                  edit mission
                </a>
              </div>
            </div>
          }
        </Layout>
      </React.Fragment>
    )
  }
}

MissionIndex.propTypes = {
  missions: PropTypes.array.isRequired
}
MissionIndex.defaultProps = {
  missions: []
}
