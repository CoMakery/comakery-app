import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd'
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
    this.onDragEnd = this.onDragEnd.bind(this)
    this.state = {
      selectedMissionId: null,
      missions         : props.missions
    }
  }

  onDragEnd(result) {
    // dropped outside the list
    if (!result.destination) {
      return
    }
    // same position
    if (result.source.index === result.destination.index) {
      return
    }
    // slice array
    const direction = result.source.index < result.destination.index ? -1 : 1
    const [startIndex, endIndex] = [Math.min(result.source.index, result.destination.index), Math.max(result.source.index, result.destination.index)]
    const subarray = this.state.missions.slice(startIndex, endIndex + 1)
    // need to update db

    fetchPolyfill(`/missions/rearrange`, {
      credentials: 'same-origin',
      headers    : {
        'Content-Type': 'application/json'
      },
      method: 'POST',
      body  : JSON.stringify({
        mission_ids         : subarray.map(mission => mission.id),
        display_orders      : subarray.map(mission => mission.displayOrder),
        direction           : direction,
        'authenticity_token': this.props.csrfToken
      })
    }).then(response => {
      if (response.status === 200) {
        // need to update frontend
        response.json().then(data => {
          this.setState({
            missions: data.missions
          })
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

  handleListClick(missionId) {
    this.setState({
      selectedMissionId: missionId
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
        let newMissions = Array.from(this.state.missions)
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
    const { missions, selectedMissionId } = this.state
    if (selectedMissionId === null) {
      return // if no mission is selected
    }
    const selectedMissionIndex = missions.findIndex(mission => mission.id === selectedMissionId) // find index of the selected mission
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
        let newMissions = Array.from(missions)
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
    const { selectedMissionId, missions } = this.state
    const selectedMission = selectedMissionId !== null
      ? missions.find(mission => mission.id === selectedMissionId) : null

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

                { missions.length > 0 &&
                  <React.Fragment>
                    <hr />

                    <div className="mission-index--sidebar--info">
                      Please select or rearrange missions you want to display on landing page:
                    </div>

                    <DragDropContext onDragEnd={this.onDragEnd}>
                      <Droppable droppableId="droppable">
                        {(provided, _) => (
                          <div
                            ref={provided.innerRef}
                          >
                            {missions.map((mission, index) => (
                              <Draggable key={mission.id} draggableId={mission.id} index={index}>
                                {(provided, _) => (
                                  <div
                                    ref={provided.innerRef}
                                    {...provided.draggableProps}
                                    {...provided.dragHandleProps}
                                  >
                                    <SidebarItem
                                      className="mission-index--sidebar--item"
                                      key={mission.id}
                                      iconRightName="REARRANGE.svg"
                                      text={mission.name}
                                      leftChild={
                                        <React.Fragment>
                                          <InputField
                                            type="checkbox"
                                            className="mission-index--sidebar--item-check"
                                            checked={mission.status === 'active'}
                                            eventHandler={() => this.updateMissionStatus(index)}
                                          />
                                        </React.Fragment>
                                      }
                                      selected={selectedMissionId === mission.id}
                                      onClick={(_) => this.handleListClick(mission.id)}
                                    />
                                  </div>
                                )}
                              </Draggable>
                            ))}
                            {provided.placeholder}
                          </div>
                        )}
                      </Droppable>
                    </DragDropContext>
                  </React.Fragment>
                }
              </div>
            </React.Fragment>
          }
        >
          {selectedMission !== null &&
            <div className="mission-index--view">
              <div className="mission-index--view--logo">
                <img
                  src={selectedMission.imagePreview}
                />
              </div>

              <div className="mission-index--view--info">
                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    name
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {selectedMission.name}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    token
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {selectedMission.tokenName}
                    {selectedMission.tokenSymbol && ` (${selectedMission.tokenSymbol})`}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    subtitle
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {selectedMission.subtitle}
                  </div>
                </div>

                <div className="mission-index--view--info--item">
                  <div className="mission-index--view--info--item--name">
                    description
                  </div>
                  <div className="mission-index--view--info--item--value">
                    {selectedMission.description}
                  </div>
                </div>
              </div>

              <div className="mission-index--view--link">
                <span>Please select projects you want to display within selected mission:</span>
                <a
                  href={`/missions/${selectedMission.id}/edit`}
                >
                  edit mission
                </a>
              </div>
            </div>
          }

          {selectedMission !== null && selectedMission.projects.length > 0 &&
            <div className="mission-index--projects">
              {selectedMission.projects.map((p, index) =>
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
