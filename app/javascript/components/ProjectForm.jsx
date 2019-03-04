import React from 'react'
import PropTypes from 'prop-types'
import Layout from './layouts/Layout'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'
import InputFieldDropdown from './styleguide/InputFieldDropdown'
import InputFieldDropdownHalfed from './styleguide/InputFieldDropdownHalfed'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescription from './styleguide/InputFieldDescription'
import Icon from './styleguide/Icon'

class ProjectForm extends React.Component {
  constructor(props) {
    super(props)

    this.errorAdd = this.errorAdd.bind(this)
    this.errorRemove = this.errorRemove.bind(this)
    this.disable = this.disable.bind(this)
    this.enable = this.enable.bind(this)
    this.addChannel = this.addChannel.bind(this)
    this.destroyChannel = this.destroyChannel.bind(this)
    this.handleChannelFieldChange = this.handleChannelFieldChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleFieldChange = this.handleFieldChange.bind(this)
    this.verifySquareImgRes = this.verifySquareImgRes.bind(this)
    this.verifyPanoramicImgRes = this.verifyPanoramicImgRes.bind(this)

    this.squareImgInputRef = React.createRef()
    this.panoramicImgInputRef = React.createRef()

    let awardVisibilitiesPretty = {
      'Only admins can see list of rewards': 'true',
      'Show all awards & contributions'    : 'false'
    }

    let visibilitiesPretty = {}
    this.props.visibilities.forEach(v => {
      switch (v) {
        case 'member':
          visibilitiesPretty['Logged in team members'] = v
          break
        case 'public_listed':
          visibilitiesPretty['Publicly listed in CoMakery searches'] = v
          break
        case 'member_unlisted':
          visibilitiesPretty['Logged in team member via unlisted URL'] = v
          break
        case 'public_unlisted':
          visibilitiesPretty['Unlisted URL (no login required)'] = v
          break
        case 'archived':
          visibilitiesPretty['Archived (visible only to me)'] = v
          break
        default:
          visibilitiesPretty[v] = v
      }
    })

    this.state = {
      flashMessages                     : [],
      errors                            : {},
      disabled                          : {},
      formAction                        : this.props.formAction,
      formUrl                           : this.props.formUrl,
      closeOnSuccess                    : false,
      awardVisibilitiesPretty           : awardVisibilitiesPretty,
      visibilitiesPretty                : visibilitiesPretty,
      id                                : this.props.project.id || null,
      'project[mission_id]'             : this.props.project.missionId || Object.values(this.props.missions)[0],
      'project[token_id]'               : this.props.project.tokenId || Object.values(this.props.tokens)[0],
      'project[visibility]'             : this.props.project.visibility || Object.values(visibilitiesPretty)[0],
      'project[require_confidentiality]': (this.props.project.requireConfidentiality === true || this.props.project.requireConfidentiality === null) ? 'true' : 'false',
      'project[url]'                    : this.props.project.url || '',
      'project[title]'                  : this.props.project.title || '',
      'project[description]'            : this.props.project.description || '',
      'project[maximum_tokens]'         : this.props.project.maximumTokens || '',
      'project[video_url]'              : this.props.project.videoUrl || '',
      'project[legal_project_owner]'    : this.props.project.legalProjectOwner || '',
      'project[channels]'               : this.props.project.channels || []
    }
  }

  errorAdd(n, e) {
    this.setState({
      errors: Object.assign({}, this.state.errors, {[n]: e})
    })
  }

  errorRemove(n) {
    let e = this.state.errors
    delete e[n]
    this.setState({
      errors: e
    })
  }

  disable(a) {
    let d = this.state.disabled
    a.forEach(n => d = Object.assign({}, d, {[n]: true}))
    this.setState({
      disabled: d
    })
  }

  enable(a) {
    let d = this.state.disabled
    a.forEach(n => delete d[n])
    this.setState({
      disabled: d
    })
  }

  addChannel() {
    this.setState(state => ({
      'project[channels]': state['project[channels]'].concat({
        channelId: this.props.teams.find(t => t.teamId === this.props.teams[0].teamId).channels[0].channelId,
        teamId   : this.props.teams[0].teamId,
        id       : `${state['project[channels]'].length + 1000000}`,
        new      : true
      })
    }))
  }

  handleChannelFieldChange(event, i) {
    let channels = this.state['project[channels]']

    if (event.target.name.match(/channel_id/)) {
      channels[i] = {
        channelId: event.target.value,
        teamId   : channels[i].teamId,
        id       : channels[i].id,
        new      : channels[i].new
      }
    } else {
      channels[i] = {
        channelId: this.props.teams.find(t => t.teamId === event.target.value).channels[0].channelId,
        teamId   : event.target.value,
        id       : channels[i].id,
        new      : channels[i].new
      }
    }

    this.setState({
      'project[channels]': channels
    })
  }

  destroyChannel(event, i) {
    let channels = this.state['project[channels]']

    channels[i] = {
      id     : channels[i].id,
      destroy: true,
      new    : channels[i].new
    }

    this.setState({
      'project[channels]': channels
    })
  }

  verifySquareImgRes(img) {
    if ((img.naturalWidth !== 800) || (img.naturalHeight !== 800)) {
      this.squareImgInputRef.current.value = ''
      this.errorAdd('project[square_image]', 'Please attach the correct image')
    } else {
      this.errorRemove('project[square_image]')
    }
  }

  verifyPanoramicImgRes(img) {
    if ((img.naturalWidth !== 1500) || (img.naturalHeight !== 300)) {
      this.panoramicImgInputRef.current.value = ''
      this.errorAdd('project[panoramic_image]', 'Please attach the correct image')
    } else {
      this.errorRemove('project[panoramic_image]')
    }
  }

  handleFieldChange(event) {
    this.setState({ [event.target.name]: event.target.value })

    if (!event.target.checkValidity()) {
      this.errorAdd(event.target.name, 'Please provide the correct value')
      return
    } else {
      this.errorRemove(event.target.name)
    }

    if (event.target.value === '') {
      return
    }
  }

  handleSubmit(event) {
    event.preventDefault()

    this.disable(['project[submit]', 'project[submit_and_close]'])

    if (!event.target.checkValidity()) {
      this.enable(['project[submit]', 'project[submit_and_close]'])
      return
    }

    const formData = new FormData(event.target)

    fetchPolyfill(this.state.formUrl, {
      credentials: 'same-origin',
      method     : this.state.formAction,
      body       : formData,
      headers    : {
        'X-Key-Inflection': 'snake'
      }
    }).then(response => {
      if (response.status === 200) {
        if (this.state.closeOnSuccess) {
          window.location = this.props.urlOnSuccess
        } else {
          response.json().then(data => {
            if (this.state.formAction === 'POST') {
              this.setState(state => ({
                formAction         : 'PUT',
                formUrl            : `/projects/${data.id}`,
                id                 : data.id,
                'project[channels]': data.props.project.channels || [],
                flashMessages      : state.flashMessages.concat([{'severity': 'notice', 'text': 'Project Created'}])
              }))
              history.replaceState(
                {},
                document.title,
                `${window.location.origin}/projects/${data.id}/edit`
              )
            } else {
              this.setState(state => ({
                'project[channels]': data.props.project.channels || [],
                flashMessages      : state.flashMessages.concat([{'severity': 'notice', 'text': 'Project Updated'}])
              }))
            }
          })
          this.enable(['project[submit]', 'project[submit_and_close]'])
        }
      } else {
        response.json().then(data => {
          this.setState(state => ({
            errors       : data.errors,
            flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': data.message}])
          }))
          this.enable(['project[submit]', 'project[submit_and_close]'])
        })
      }
    })
  }

  goBack() {
    typeof window === 'undefined' ? null : window.location = '/projects'
  }

  render() {
    return (
      <React.Fragment>
        <Layout
          className="project-form"
          navTitle={[
            {
              name: 'project settings',
              current: true
            },
            {
              name: 'batches',
              url : this.state.id ? `/projects/${this.state.id}/award_types` : '#'
            }
          ]}
          subfooter={
            <React.Fragment>
              <Button
                value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
                type="submit"
                form="project-form--form"
                disabled={this.state.disabled['project[submit_and_close]']}
                onClick={() => this.setState({closeOnSuccess: true})}
              />
              <ButtonBorder
                value={this.state.formAction === 'POST' ? 'create' : 'save'}
                type="submit"
                form="project-form--form"
                disabled={this.state.disabled['project[submit]']}
                onClick={() => this.setState({closeOnSuccess: false})}
              />
              <ButtonBorder
                value="cancel"
                onClick={this.goBack}
              />
            </React.Fragment>
          }
        >
          <Flash messages={this.state.flashMessages} />

          <form className="project-form--form" id="project-form--form" onSubmit={this.handleSubmit}>
            <InputFieldDropdown
              title="mission"
              required
              name="project[mission_id]"
              value={this.state['project[mission_id]'] ? this.state['project[mission_id]'].toString() : null}
              errorText={this.state.errors['project[mission_id]']}
              disabled={this.state.disabled['project[mission_id]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.missions)}
              symbolLimit={0}
            />

            <InputFieldDropdown
              title="token"
              required
              name="project[token_id]"
              value={this.state['project[token_id]'] ? this.state['project[token_id]'].toString() : null}
              errorText={this.state.errors['project[token_id]']}
              disabled={this.state.disabled['project[token_id]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.props.tokens)}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="title"
              required
              name="project[title]"
              value={this.state['project[title]']}
              errorText={this.state.errors['project[title]']}
              placeholder="Provide a name for the project"
              eventHandler={this.handleFieldChange}
              symbolLimit={100}
            />

            <InputFieldDescription
              title="description"
              required
              name="project[description]"
              value={this.state['project[description]']}
              errorText={this.state.errors['project[description]']}
              placeholder="Explain the outline and goal of the project, and why people should be excited about helping to execute the vision"
              eventHandler={this.handleFieldChange}
              symbolLimit={250}
            />

            <InputFieldWhiteDark
              title="narrated video overview"
              recommended
              name="project[video_url]"
              value={this.state['project[video_url]']}
              errorText={this.state.errors['project[video_url]']}
              placeholder="Paste in a link to a YouTube or Vimeo video detailing the project"
              eventHandler={this.handleFieldChange}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="total budget"
              recommended
              name="project[maximum_tokens]"
              value={this.state['project[maximum_tokens]'] ? this.state['project[maximum_tokens]'].toString() : ''}
              errorText={this.state.errors['project[maximum_tokens]']}
              placeholder="Provide the budget for completing the entire project"
              pattern="\d+"
              eventHandler={this.handleFieldChange}
              symbolLimit={0}
              readOnly={this.state.formAction !== 'POST'}
            />

            <InputFieldDropdown
              title="project visibility"
              required
              name="project[visibility]"
              value={this.state['project[visibility]']}
              errorText={this.state.errors['project[visibility]']}
              disabled={this.state.disabled['project[visibility]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.state.visibilitiesPretty)}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="project url"
              required
              readOnly
              copyOnClick
              name="project[url]"
              value={this.state['project[url]']}
              errorText={this.state.errors['project[url]']}
              eventHandler={this.handleFieldChange}
              symbolLimit={0}
            />

            <InputFieldDropdown
              title="awards visibility"
              required
              name="project[require_confidentiality]"
              value={this.state['project[require_confidentiality]']}
              errorText={this.state.errors['project[require_confidentiality]']}
              disabled={this.state.disabled['project[require_confidentiality]']}
              eventHandler={this.handleFieldChange}
              selectEntries={Object.entries(this.state.awardVisibilitiesPretty)}
              symbolLimit={0}
            />

            <InputFieldWhiteDark
              title="legal owner of the project"
              required
              name="project[legal_project_owner]"
              value={this.state['project[legal_project_owner]']}
              errorText={this.state.errors['project[legal_project_owner]']}
              placeholder="Provide a legal entity or individual owner's name"
              eventHandler={this.handleFieldChange}
              symbolLimit={0}
            />

            <InputFieldUploadFile
              title="project image – square"
              required
              name="project[square_image]"
              errorText={this.state.errors['project[square_image]']}
              imgPreviewUrl={this.props.project.squareImageUrl}
              imgPreviewDimensions="100x100"
              imgRequirements="Image should be at least 800px x 800px"
              imgVerifier={this.verifySquareImgRes}
              imgInputRef={this.squareImgInputRef}
            />

            <InputFieldUploadFile
              title="project image – panoramic"
              required
              name="project[panoramic_image]"
              errorText={this.state.errors['project[panoramic_image]']}
              imgPreviewUrl={this.props.project.panoramicImageUrl}
              imgPreviewDimensions="375x75"
              imgRequirements="Image should be at least 1500px x 300px"
              imgVerifier={this.verifyPanoramicImgRes}
              imgInputRef={this.panoramicImgInputRef}
            />

            <input
              type="hidden"
              name="project[long_id]"
              value={this.props.project.longId}
              readOnly
            />

            <input
              type="hidden"
              name="authenticity_token"
              value={this.props.csrfToken}
              readOnly
            />

            <div className="project-form--form--channels--header">
              COMMUNICATION CHANNELS
            </div>

            {this.props.teams.length > 0 && this.state['project[channels]'].map((c, i) =>
              <div className="project-form--form--channels--channel" key={i}>
                <input
                  type="hidden"
                  name={`project[channels_attributes][${c.id}][id]`}
                  value={c.new ? '' : c.id}
                />

                {!c.destroy &&
                  <React.Fragment>
                    <InputFieldDropdownHalfed
                      required
                      className="project-form--form--channels--channel--select"
                      title="team or guild"
                      name={`project[channels_attributes][${c.id}][team_id]`}
                      value={this.state['project[channels]'][i].teamId}
                      eventHandler={(e) => this.handleChannelFieldChange(e, i)}
                      selectEntries={this.props.teams.map(t => [t.team, t.teamId])}
                    />
                    <InputFieldDropdownHalfed
                      required
                      className="project-form--form--channels--channel--select"
                      title="channel"
                      name={`project[channels_attributes][${c.id}][channel_id]`}
                      value={this.state['project[channels]'][i].channelId}
                      eventHandler={(e) => this.handleChannelFieldChange(e, i)}
                      selectEntries={c.teamId ? this.props.teams.find(t => t.teamId === c.teamId).channels.map(ch => [ch.channel, ch.channelId]) : []}
                    />
                    <div className="project-form--form--channels--channel--del" onClick={(e) => this.destroyChannel(e, i)}>
                      <Icon name="iconTrash.svg" />
                    </div>
                  </React.Fragment>
                }

                {c.destroy && !c.new &&
                  <input
                    type="hidden"
                    name={`project[channels_attributes][${c.id}][_destroy]`}
                    value="1"
                  />
                }
              </div>
            )}

            {this.props.teams.length > 0 &&
              <div className="project-form--form--channels--add" onClick={this.addChannel}>
                Add Channel +
              </div>
            }

            {this.props.teams.length === 0 &&
              <div className="project-form--form--channels--empty">
                Start adding channels by signing in with Slack or Discord
              </div>
            }
          </form>
        </Layout>
      </React.Fragment>
    )
  }
}

ProjectForm.propTypes = {
  project     : PropTypes.object.isRequired,
  tokens      : PropTypes.object.isRequired,
  missions    : PropTypes.object.isRequired,
  visibilities: PropTypes.array.isRequired,
  teams       : PropTypes.array.isRequired,
  formUrl     : PropTypes.string.isRequired,
  formAction  : PropTypes.string.isRequired,
  urlOnSuccess: PropTypes.string.isRequired,
  csrfToken   : PropTypes.string.isRequired
}
ProjectForm.defaultProps = {
  project     : {'default': '_'},
  tokens      : {'default': '_'},
  missions    : {'default': '_'},
  visibilities: [],
  teams       : [],
  formUrl     : '/',
  formAction  : 'POST',
  urlOnSuccess: '/',
  csrfToken   : '00'
}
export default ProjectForm
