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
    this.verifyWhitelableLogoRes = this.verifyWhitelableLogoRes.bind(this)
    this.verifyWhitelableLogoDarkRes = this.verifyWhitelableLogoDarkRes.bind(this)
    this.verifyWhitelabelFaviconRes = this.verifyWhitelabelFaviconRes.bind(this)
    this.verifyImgSize = this.verifyImgSize.bind(this)

    this.imageInputRef = React.createRef()
    this.logoInputRef = React.createRef()
    this.whitelabelLogoInputRef = React.createRef()
    this.whitelabelLogoDarkInputRef = React.createRef()
    this.whitelabelFaviconInputRef = React.createRef()

    this.state = {
      errors                     : {}, // error hash for account form
      disabled                   : {}, // disabled hash
      flashMessages               : [],
      formAction                 : this.props.formAction,
      formUrl                    : this.props.formUrl,
      closeOnSuccess             : false,
      name                       : props.mission.name || '',
      subtitle                   : props.mission.subtitle || '',
      description                : props.mission.description || '',
      whitelabel                 : props.mission.whitelabel ? 'true' : 'false',
      whitelabelDomain           : props.mission.whitelabelDomain || '',
      whitelabelContactEmail     : props.mission.whitelabelContactEmail || '',
      whitelabelApiPublicKey     : props.mission.whitelabelApiPublicKey || '',
      walletRecoveryApiPublicKey : props.mission.walletRecoveryApiPublicKey || '',
      logo                       : null,
      image                      : null,
      logoPreview                : props.mission.logoUrl,
      imagePreview               : props.mission.imageUrl,
      whitelabelLogo             : null,
      whitelabelLogoDark         : null,
      whitelabelFavicon          : null,
      whitelabelLogoPreview      : props.mission.whitelabelLogoUrl,
      whitelabelLogoDarkPreview  : props.mission.whitelabelLogoDarkUrl,
      whitelabelFaviconPreview   : props.mission.whitelabelFaviconUrl
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
      [name]: value
    })

    this.verifyImgSize(e)

    const errorMessage = 'invalid value'
    if (!e.target.checkValidity()) {
      this.errorAdd(e.target.name, errorMessage)
      return
    } else {
      this.errorRemove(e.target.name, errorMessage)
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
    const {
      name,
      subtitle,
      description,
      whitelabel,
      whitelabelDomain,
      whitelabelContactEmail,
      whitelabelApiPublicKey,
      walletRecoveryApiPublicKey,
      logo,
      image,
      whitelabelLogo,
      whitelabelLogoDark,
      whitelabelFavicon
    } = this.state

    formData.append('mission[name]', name)
    formData.append('mission[subtitle]', subtitle)
    formData.append('mission[description]', description)
    formData.append('mission[whitelabel]', whitelabel)
    formData.append('mission[whitelabel_domain]', whitelabelDomain)
    formData.append('mission[whitelabel_contact_email]', whitelabelContactEmail)
    formData.append('mission[whitelabel_api_public_key]', whitelabelApiPublicKey)
    formData.append('mission[wallet_recovery_api_public_key]', walletRecoveryApiPublicKey)
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
    if (whitelabelFavicon) {
      formData.append('mission[whitelabel_favicon]', whitelabelFavicon)
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
    const errorMessage = 'invalid resolution'
    if ((img.naturalWidth < 1200) || (img.naturalHeight < 800) || (img.naturalWidth / img.naturalHeight !== 1.5)) {
      this.imageInputRef.current.value = ''
      this.errorAdd('image', errorMessage)
    } else {
      this.errorRemove('image', errorMessage)
    }
  }

  verifyLogoRes(img) {
    const errorMessage = 'invalid resolution'

    if ((img.naturalWidth < 800) || (img.naturalHeight < 800) || (img.naturalWidth / img.naturalHeight !== 1)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('logo', errorMessage)
    } else {
      this.errorRemove('logo', errorMessage)
    }
  }

  verifyWhitelableLogoRes(img) {
    const errorMessage = 'invalid resolution'

    if ((img.naturalWidth < 1000) || (img.naturalHeight < 200) || (img.naturalWidth / img.naturalHeight !== 5)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('whitelabelLogo', errorMessage)
    } else {
      this.errorRemove('whitelabelLogo', errorMessage)
    }
  }

  verifyWhitelableLogoDarkRes(img) {
    const errorMessage = 'invalid resolution'

    if ((img.naturalWidth < 1000) || (img.naturalHeight < 200) || (img.naturalWidth / img.naturalHeight !== 5)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('whitelabelLogoDark', errorMessage)
    } else {
      this.errorRemove('whitelabelLogoDark', errorMessage)
    }
  }

  verifyWhitelabelFaviconRes(img) {
    const errorMessage = 'invalid resolution'

    if ((img.naturalWidth < 64) || (img.naturalHeight < 64) || (img.naturalWidth / img.naturalHeight !== 1)) {
      this.logoInputRef.current.value = ''
      this.errorAdd('whitelabelFavicon', errorMessage)
    } else {
      this.errorRemove('whitelabelFavicon', errorMessage)
    }
  }

  verifyImgSize(event) {
    let file = event.target.files[0]

    if (file && file.size) {
      const errorMessage = 'Image size must me less then 2 megabytes'
      const fileSizeMb = file.size / Math.pow(1024, 2)
      const maxSize = 2

      if (fileSizeMb > maxSize) {
        this.errorAdd(event.target.name, errorMessage)
      } else {
        this.errorRemove(event.target.name, errorMessage)
      }
    }
  }

  errorAdd(key, e) {
    let errors = this.state.errors

    if (errors.hasOwnProperty(key)) {
      if (errors[key].includes(e)) {
        return
      }

      this.setState({
        errors: Object.assign({}, errors, {[key]: [...errors[key], e]})
      })
    } else {
      this.setState({
        errors: Object.assign({}, errors, {[key]: Object.assign([], errors[key], [e])})
})
    }
  }

  errorRemove(key, e) {
    let errors = this.state.errors
    let index = errors[key].indexOf(e)

    errors[key].splice(index, 1)

    this.setState({
      errors: errors
    })
  }

  disable(a) {
    let d = this.state.disabled
    a.forEach(n => (d = Object.assign({}, d, {[n]: true})))
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
    const {
      name,
      subtitle,
      description,
      whitelabel,
      whitelabelDomain,
      whitelabelContactEmail,
      whitelabelApiPublicKey,
      walletRecoveryApiPublicKey,
      logoPreview,
      imagePreview,
      whitelabelLogoPreview,
      whitelabelLogoDarkPreview,
      whitelabelFaviconPreview,
      errors
    } = this.state

    return <React.Fragment>
      <Layout
        className='mission-form'
        title={this.state.formAction === 'POST' ? 'Create a New Mission' : 'Edit Mission'}
        hasBackButton
        subfooter={
          <React.Fragment>
            <Button
              value={this.state.formAction === 'POST' ? 'create & close' : 'save & close'}
              type='submit'
              form='mission-form--form'
              className='button--right-space'
              disabled={this.state.disabled.submit_and_close}
              onClick={() => this.setState({closeOnSuccess: true})}
            />
            <ButtonBorder
              value={this.state.formAction === 'POST' ? 'create' : 'save'}
              type='submit'
              form='mission-form--form'
              className='button--right-space'
              disabled={this.state.disabled.submit}
              onClick={() => this.setState({closeOnSuccess: false})}
            />
            <ButtonBorder
              value='cancel'
              onClick={this.goBack}
            />
          </React.Fragment>
        }
      >

        <Flash messages={this.state.flashMessages} />

        <form id='mission-form--form' className='mission-form--form' onSubmit={this.handleSaveMission}>
          <InputFieldWhiteDark
            name='name' title='Name' symbolLimit={100} required value={name}
            placeholder='Unicoin'
            eventHandler={this.handleChangeFormData}
            errors={errors.name} />

          <InputFieldWhiteDark
            name='subtitle' title='Subtitle' symbolLimit={140} required value={subtitle}
            placeholder='Unicoin is the future of tokenizing fantastical beast networks'
            eventHandler={this.handleChangeFormData}
            errors={errors.subtitle} />

          <InputFieldDescription
            name='description' title='Description' symbolLimit={500} required value={description}
            placeholder='Here will be templated text but with lower opacity as lower opacity indicates that it is a placeholder. When user start to type within field, text should have 100% opacity.'
            eventHandler={this.handleChangeFormData}
            errors={errors.description}
          />

          <InputFieldUploadFile
            name='logo' title='Mission Logo'
            required
            imgPreviewDimensions='100x100'
            imgPreviewUrl={logoPreview}
            imgRequirements='Image should be at least 800px x 800px'
            imgVerifier={this.verifyLogoRes}
            imgInputRef={this.logoInputRef}
            eventHandler={this.handleChangeFormData}
            errors={errors.logo}
          />

          <InputFieldUploadFile
            name='image' title='Mission Image'
            required
            imgPreviewDimensions='150x100'
            imgPreviewUrl={imagePreview}
            imgRequirements='Image should be at least 1200px x 800px'
            imgVerifier={this.verifyImageRes}
            imgInputRef={this.imageInputRef}
            eventHandler={this.handleChangeFormData}
            errors={errors.image}
          />

          <InputFieldDropdown
            title='Whitelabel'
            required
            name='whitelabel'
            value={whitelabel}
            eventHandler={this.handleChangeFormData}
            selectEntries={Object.entries({'Enabled': 'true', 'Disabled': 'false'})}
            symbolLimit={0}
          />

          <InputFieldWhiteDark
            name='whitelabelDomain'
            title='Whitelabel Domain'
            symbolLimit={140}
            value={whitelabelDomain}
            eventHandler={this.handleChangeFormData}
          />

          <InputFieldWhiteDark
            name='whitelabelContactEmail'
            title='Whitelabel Contact Email'
            symbolLimit={140}
            value={whitelabelContactEmail}
            eventHandler={this.handleChangeFormData}
          />

          <InputFieldWhiteDark
            name='whitelabelApiPublicKey'
            title='Whitelabel API Public Key'
            symbolLimit={140}
            value={whitelabelApiPublicKey}
            readOnly={this.props.mission.whitelabelApiPublicKey}
            eventHandler={this.handleChangeFormData}
          />

          <InputFieldWhiteDark
            name='walletRecoveryApiPublicKey'
            title='Wallet recovery API Public Key'
            symbolLimit={68}
            value={walletRecoveryApiPublicKey}
            readOnly={this.props.mission.walletRecoveryApiPublicKey}
            eventHandler={this.handleChangeFormData}
          />

          <InputFieldUploadFile
            name='whitelabelLogo'
            title='Mission Whitelabel Logo'
            imgPreviewDimensions='150x100'
            imgPreviewUrl={whitelabelLogoPreview}
            imgRequirements='Image should be at least 1000px x 200px'
            imgVerifier={this.verifyWhitelableLogoRes}
            imgInputRef={this.whitelabelLogoInputRef}
            eventHandler={this.handleChangeFormData}
            errors={errors.whitelabelLogo}
          />

          <InputFieldUploadFile
            name='whitelabelLogoDark'
            title='Mission Whitelabel Logo Dark'
            imgPreviewDimensions='150x100'
            imgPreviewUrl={whitelabelLogoDarkPreview}
            imgRequirements='Image should be at least 1000px x 200px'
            imgVerifier={this.verifyWhitelableLogoDarkRes}
            imgInputRef={this.whitelabelLogoDarkInputRef}
            eventHandler={this.handleChangeFormData}
            errors={errors.whitelabelLogoDark}
          />

          <InputFieldUploadFile
            name='whitelabelFavicon'
            title='Mission Whitelabel Favicon'
            imgPreviewDimensions='100x100'
            imgPreviewUrl={whitelabelFaviconPreview}
            imgRequirements='Image should be at least 64px x 64px'
            imgVerifier={this.verifyWhitelabelFaviconRes}
            imgInputRef={this.whitelabelFaviconInputRef}
            eventHandler={this.handleChangeFormData}
            errors={errors.whitelabelFavicon}
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
