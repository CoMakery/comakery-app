import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescription from './styleguide/InputFieldDescription'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import InputFieldDropdown from './styleguide/InputFieldDropdown'
import Button from './styleguide/Button'
import ButtonBorder from './styleguide/ButtonBorder'
import Flash from './layouts/Flash'
import Layout from './layouts/Layout'

export default class MissionForm extends React.Component {
  constructor(props) {
    super(props)

    this.goBack = this.goBack.bind(this)
    this.errorAdd = this.errorAdd.bind(this)
    this.errorRemove = this.errorRemove.bind(this)
    this.disable = this.disable.bind(this)
    this.enable = this.enable.bind(this)
    this.handleChangeFormData = this.handleChangeFormData.bind(this)
    this.handleSaveMission = this.handleSaveMission.bind(this)
    this.verifyImageRes = this.verifyImageRes.bind(this)
    this.verifyLogoRes = this.verifyLogoRes.bind(this)

    this.imageInputRef = React.createRef()
    this.logoInputRef = React.createRef()
    this.whitelabelLogoInputRef = React.createRef()
    this.whitelabelLogoDarkInputRef = React.createRef()

    this.state = {
      errors                   : {}, // error hash for account form
      disabled                 : {}, // disabled hash
      flashMessages            : [],
      formAction               : this.props.formAction,
      formUrl                  : this.props.formUrl,
      closeOnSuccess           : false,
      name                     : props.mission.name || '',
      subtitle                 : props.mission.subtitle || '',
      description              : props.mission.description || '',
      whitelabel               : props.mission.whitelabel ? 'true' : 'false',
      whitelabelDomain         : props.mission.whitelabelDomain || '',
      logo                     : null,
      image                    : null,
      logoPreview              : props.mission.logoUrl,
      imagePreview             : props.mission.imageUrl,
      whitelabelLogo           : null,
      whitelabelLogoDark       : null,
      whitelabelLogoPreview    : props.mission.whitelabelLogoUrl,
      whitelabelLogoDarkPreview: props.mission.whitelabelLogoDarkUrl
    }
    this.mounted = false
  }

  componentDidMount() {
    this.mounted = true
  }

  componentWillMount() {
    this.mounted = false
  }

  handleChangeFormData(e) {
    const target = e.target
    let value
    switch (target.type) {
      case 'checkbox':
        value = target.checked
        break
      case 'file':
        value = target.files[0]
        break
      default:
        value = target.value
    }
    const name = target.name
    this.setState({
      [name]: value,
    })

    if (!e.target.checkValidity()) {
      this.errorAdd(e.target.name, 'invalid value')
      return
    } else {
      this.errorRemove(e.target.name)
    }
  }

  handleSaveMission(e) {
    e.preventDefault()

    this.disable(['submit', 'submit_and_close'])

    if (!e.target.checkValidity()) {
      this.enable(['submit', 'submit_and_close'])
      return
    }

    let formData = new FormData()
    const {name, subtitle, description, whitelabel, whitelabelDomain, logo, image, whitelabelLogo, whitelabelLogoDark} = this.state
    formData.append('mission[name]', name)
    formData.append('mission[subtitle]', subtitle)
    formData.append('mission[description]', description)
    formData.append('mission[whitelabel]', whitelabel)
    formData.append('mission[whitelabel_domain]', whitelabelDomain)
    formData.append('authenticity_token', this.props.csrfToken)
    if (logo) {
      formData.append('mission[logo]', logo)
    }
    if (whitelabelLogo) {
      formData.append('mission[whitelabel_logo]', whitelabelLogo)
    }
    if (whitelabelLogoDark) {
      formData.append('mission[whitelabel_logo_dark]', whitelabelLogoDark)
    }
    if (image) {
      formData.append('mission[image]', image)
    }
    fetchPolyfill(this.state.formUrl, {
      credentials: 'same-origin',
      method     : this.state.formAction,
      body       : formData
    }).then(response => {
      if (response.status === 200) {
        if (this.state.closeOnSuccess) {
          window.location = this.props.urlOnSuccess
        } else {
          if (this.state.formAction === 'POST') {
            response.json().then(data => {
              this.setState(state => ({
                formAction   : 'PUT',
                formUrl      : `/missions/${data.id}`,
                flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': 'Mission Created'}])
              }))
              history.replaceState(
                {},
                document.title,
                `${window.location.origin}/missions/${data.id}/edit`
              )
            })
          } else {
            this.setState(state => ({
              flashMessages: state.flashMessages.concat([{'severity': 'notice', 'text': 'Mission Updated'}])
            }))
          }
          this.enable(['submit', 'submit_and_close'])
        }
      } else {
        response.json().then(data => {
          this.setState(state => ({
            errors       : data.errors,
            flashMessages: state.flashMessages.concat([{'severity': 'error', 'text': data.message}])
          }))
          this.enable(['submit', 'submit_and_close'])
        })
      }
    })
  }

  verifyImageRes(img) {
    if ((img.naturalWidth < 1200) || (img.naturalHeight < 800) || (img.naturalWidth / img.naturalHeight !== 1.5)) {
      this.imageInputRef.current.value = ''
      this.errorAdd('image', 'invalid resolution')
    } else {
      this.errorRemove('image')
    }
  }

  verifyLogoRes(img) {
    if ((img.naturalWidth < 800) || (img.naturalHeight < 800) || (img.naturalWidth / img.naturalHeight !== 1)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('logo', 'invalid resolution')
    } else {
      this.errorRemove('logo')
    }
  }

  verifyWhitelableLogoRes(img) {
    if ((img.naturalWidth < 1000) || (img.naturalHeight < 200) || (img.naturalWidth / img.naturalHeight !== 5)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('whitelabelLogo', 'invalid resolution')
    } else {
      this.errorRemove('whitelabelLogo')
    }
  }

  verifyWhitelableLogoDarkRes(img) {
    if ((img.naturalWidth < 1000) || (img.naturalHeight < 200) || (img.naturalWidth / img.naturalHeight !== 5)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('whitelabelLogoDark', 'invalid resolution')
    } else {
      this.errorRemove('whitelabelLogoDark')
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

  goBack() {
    typeof window === 'undefined' ? null : window.history.back()
  }

  render() {
    const {name, subtitle, description, whitelabel, whitelabelDomain, logoPreview, imagePreview, whitelabelLogoPreview, whitelabelLogoDarkPreview, errors} = this.state

    return <React.Fragment>
      <Layout
        className="mission-form"
        title={this.state.formAction === 'POST' ? 'Create a New Mission' : 'Edit Mission'}
        hasBackButton
        subfooter={
          <React.Fragment>
            <Button
              value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
              type="submit"
              form="mission-form--form"
              className="button--right-space"
              disabled={this.state.disabled.submit_and_close}
              onClick={() => this.setState({closeOnSuccess: true})}
            />
            <ButtonBorder
              value={this.state.formAction === 'POST' ? 'create' : 'save'}
              type="submit"
              form="mission-form--form"
              className="button--right-space"
              disabled={this.state.disabled.submit}
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

        <form id="mission-form--form" className="mission-form--form" onSubmit={this.handleSaveMission}>
          <InputFieldWhiteDark
            name="name" title="Name" symbolLimit={100} required value={name}
            placeholder="Unicoin"
            eventHandler={this.handleChangeFormData}
            errorText={errors.name} />

          <InputFieldWhiteDark
            name="subtitle" title="Subtitle" symbolLimit={140} required value={subtitle}
            placeholder="Unicoin is the future of tokenizing fantastical beast networks"
            eventHandler={this.handleChangeFormData}
            errorText={errors.subtitle} />

          <InputFieldDescription
            name="description" title="Description" symbolLimit={500} required value={description}
            placeholder="Here will be templated text but with lower opacity as lower opacity indicates that it is a placeholder. When user start to type within field, text should have 100% opacity."
            eventHandler={this.handleChangeFormData}
            errorText={errors.description}
          />

          <InputFieldUploadFile
            name="logo" title="Mission Logo"
            required
            imgPreviewDimensions="100x100"
            imgPreviewUrl={logoPreview}
            imgRequirements="Image should be at least 800px x 800px"
            imgVerifier={this.verifyLogoRes}
            imgInputRef={this.logoInputRef}
            eventHandler={this.handleChangeFormData}
            errorText={errors.logo}
          />

          <InputFieldUploadFile
            name="image" title="Mission Image"
            required
            imgPreviewDimensions="150x100"
            imgPreviewUrl={imagePreview}
            imgRequirements="Image should be at least 1200px x 800px"
            imgVerifier={this.verifyImageRes}
            imgInputRef={this.imageInputRef}
            eventHandler={this.handleChangeFormData}
            errorText={errors.image}
          />

          <InputFieldDropdown
            title="Whitelabel"
            required
            name="whitelabel"
            value={whitelabel}
            eventHandler={this.handleChangeFormData}
            selectEntries={Object.entries({'Enabled': 'true', 'Disabled': 'false'})}
            symbolLimit={0}
          />

          <InputFieldWhiteDark
            name="whitelabelDomain"
            title="Whitelabel Domain"
            symbolLimit={140}
            value={whitelabelDomain}
            eventHandler={this.handleChangeFormData}
          />

          <InputFieldUploadFile
            name="whitelabelLogo"
            title="Mission Whitelabel Logo"
            imgPreviewDimensions="150x100"
            imgPreviewUrl={whitelabelLogoPreview}
            imgRequirements="Image should be at least 1000px x 200px"
            imgVerifier={this.verifyWhitelableLogoRes}
            imgInputRef={this.whitelabelLogoInputRef}
            eventHandler={this.handleChangeFormData}
            errorText={errors.whitelabelLogo}
          />

          <InputFieldUploadFile
            name="whitelabelLogoDark"
            title="Mission Whitelabel Logo Dark"
            imgPreviewDimensions="150x100"
            imgPreviewUrl={whitelabelLogoDarkPreview}
            imgRequirements="Image should be at least 1000px x 200px"
            imgVerifier={this.verifyWhitelableLogoDarkRes}
            imgInputRef={this.whitelabelLogoDarkInputRef}
            eventHandler={this.handleChangeFormData}
            errorText={errors.whitelabelLogoDark}
          />
        </form>
      </Layout>
    </React.Fragment>
  }
}

MissionForm.propTypes = {
  mission     : PropTypes.shape({}).isRequired,
  formUrl     : PropTypes.string.isRequired,
  formAction  : PropTypes.string.isRequired,
  urlOnSuccess: PropTypes.string.isRequired,
  csrfToken   : PropTypes.string.isRequired
}

MissionForm.defaultProps = {
  mission     : {},
  formUrl     : '/',
  formAction  : 'POST',
  urlOnSuccess: '/',
  csrfToken   : '00'
}
