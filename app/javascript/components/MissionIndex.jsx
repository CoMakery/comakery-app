import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import Layout from './layouts/Layout'
import SidebarItem from './styleguide/SidebarItem'
import SidebarItemBold from './styleguide/SidebarItemBold'
import InputField from './styleguide/InputField'
import Icon from './styleguide/Icon'

export default class MissionIndex extends React.Component {
  constructor(props) {
    super(props)
    this.handleListClick = this.handleListClick.bind(this)
    this.updateMissionStatus = this.updateMissionStatus.bind(this)
    this.updateProjectStatus = this.updateProjectStatus.bind(this)
    this.state = {
      selectedMissionIndex: null,
      missions            : props.missions
    }
  }

  handleListClick(index) {
    console.log(index, this.state.missions)
    this.setState({
      selectedMissionIndex: index
    })
  }

  updateMissionStatus(index) {
    const mission = this.state.missions[index]
    const status = mission.status === 'active' ? 'passive' : 'active'

    fetchPolyfill(`/missions/${mission.id}`, {
      credentials: 'same-origin',
      headers    : {
        'Content-Type': 'application/json'
      },
      method: 'PATCH',
      body  : JSON.stringify({
        mission             : {status: status},
        'authenticity_token': this.props.csrfToken
      })
    }).then(response => {
      if (response.status === 200) {
        let newMissions = this.state.missions
        newMissions[index].status = status
        this.setState({
          missions: newMissions
        })
      } else {
        response.json().then(data => {
          this.setState({
            errors      : data.errors,
            errorMessage: data.message
          })
        })
      }
    })
  }

  updateProjectStatus(index) {
    const { missions, selectedMissionIndex } = this.state
    const project = missions[selectedMissionIndex].projects[index]
    const status = project.status === 'active' ? 'passive' : 'active'

    fetchPolyfill('/projects/update_status', {
      credentials: 'same-origin',
      headers    : {
        'Content-Type': 'application/json'
      },
      method: 'PATCH',
      body  : JSON.stringify({
        'project_id'        : project.id,
        'status'            : status,
        'authenticity_token': this.props.csrfToken
      })
    }).then(response => {
      if (response.status === 200) {
        let newMissions = missions
        newMissions[selectedMissionIndex].projects[index].status = status
        this.setState({
          missions: newMissions
        })
      } else {
        response.json().then(data => {
          this.setState({
            errors      : data.errors,
            errorMessage: data.message
          })
        })
      }
    })
  }

  render() {
    const { selectedMissionIndex, missions } = this.state
    return (
      <React.Fragment>
        <Layout
          className="mission-index"
          category="Missions > "
          title="Configure mission’s landing page"
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

                { missions.length > 0 &&
                  <React.Fragment>
                    <div className="mission-index--sidebar--info">
                      Please select or rearrange missions you want to display on landing page:
                    </div>

                    {missions.map((t, index) =>
                      <SidebarItem
                        className="mission-index--sidebar--item"
                        key={t.id}
                        iconRightName="REARRANGE.svg"
                        text={t.name}
                        leftChild={
                          <React.Fragment>
                            <InputField
                              type="checkbox"
                              className="mission-index--sidebar--item-check"
                              checked={t.status === 'active'}
                              eventHandler={() => this.updateMissionStatus(index)}
                            />
                          </React.Fragment>
                        }
                        selected={selectedMissionIndex === index}
                        onClick={(_) => this.handleListClick(index)}
                      />
                    )}
                  </React.Fragment>
                }
              </div>
            </React.Fragment>
          }
        >
          {selectedMissionIndex !== null &&
            <div className="mission-index--view">
              <div className="mission-index--view--logo">
                <img
                  src={missions[selectedMissionIndex].imagePreview}
                />
              </div>

              <div className="mission-index--view--info">
                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    name
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {missions[selectedMissionIndex].name}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    token
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {missions[selectedMissionIndex].tokenName}
                    {missions[selectedMissionIndex].tokenSymbol && ` (${missions[selectedMissionIndex].tokenSymbol})`}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    subtitle
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {missions[selectedMissionIndex].subtitle}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    description
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {missions[selectedMissionIndex].description}
                  </div>
                </div>
              </div>

              <div className="mission-index--view--link">
                <span>Please select projects you want to display within selected mission:</span>
                <a
                  href={`/missions/${missions[selectedMissionIndex].id}/edit`}
                >
                  edit mission
                </a>
              </div>
            </div>
          }

          {selectedMissionIndex !== null && missions[selectedMissionIndex].projects.length > 0 &&
            <div className="mission-index--projects">
              {missions[selectedMissionIndex].projects.map((p, index) =>
                <div key={p.id} className="mission-index--project-single">
                  <div className="mission-index--project-single--left">
                    <InputField
                      type="checkbox"
                      className="mission-index--project-single--check"
                      checked={p.status === 'active'}
                      eventHandler={() => this.updateProjectStatus(index)}
                    />
                    {p.title}
                  </div>
                  <Icon name="iconDropDownCopy.svg" className="styleguide-index--icon mission-index--project-dropdown" />
                </div>
              )}
            </div>
          }

        </Layout>
      </React.Fragment>
    )
  }
}

MissionIndex.propTypes = {
  missions : PropTypes.array.isRequired,
  csrfToken: PropTypes.string.isRequired
}
MissionIndex.defaultProps = {
  missions : [],
  csrfToken: '00'
}
