import React from 'react'
import PropTypes from 'prop-types'
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import InputFieldWhiteDark from './styleguide/InputFieldWhiteDark'
import InputFieldDescription from './styleguide/InputFieldDescription'
import InputFieldDropdownHalfed from './styleguide/InputFieldDropdownHalfed'
import InputFieldUploadFile from './styleguide/InputFieldUploadFile'
import Layout from './layouts/Layout'

export default class Mission extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      id          : props.mission.id,
      name        : props.mission.name || '',
      token       : props.mission.tokenId || undefined,
      subtitle    : props.mission.subtitle || '',
      description : props.mission.description || '',
      logoPreview : props.mission.logoPreview,
      imagePreview: props.mission.imagePreview,
      logo        : null,
      image       : null,
      errors      : {}, // error hash for account form
    }
    this.mounted = false
  }

  componentDidMount() {
    this.mounted = true
  }

  componentWillMount() {
    this.mounted = false
  }

  handleChangeFormData = e => {
    console.log('--> change', e)
    const target = e.target
    let value
    console.log(target.type)
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
  };

  handleSaveMission = e => {
    e.preventDefault()
    let formData = new FormData()
    const {name, token, subtitle, description, logo, image} = this.state
    formData.append('mission[name]', name)
    formData.append('mission[token_id]', token)
    formData.append('mission[subtitle]', subtitle)
    formData.append('mission[description]', description)
    formData.append('authenticity_token', this.props.csrfToken)
    if (logo) {
      formData.append('mission[logo]', logo)
    }
    if (image) {
      formData.append('mission[image]', image)
    }

    fetchPolyfill(this.props.formUrl, {
      credentials: 'same-origin',
      method     : this.props.id ? 'PATCH' : 'POST',
      body       : formData
    }).then(response => {
      if (response.status === 200) {
        window.location = this.props.urlOnSuccess
      } else {
        response.json().then(data => {
          this.setState({
            errors: data.errors
          })
        })
      }
    })
  }

  render() {
    const {id, name, subtitle, token, description, logoPreview, imagePreview, errors} = this.state

    return <React.Fragment>
      <Layout
        className="styleguide-index"
        title={!id ? 'Create a New Mission' : 'Edit Mission'}
        hasBackButton
        hasSubFooter
        saveButtonHandler={this.handleSaveMission}
        cancelButtonHandler={() => { window.location = this.props.urlOnSuccess }}
      >
        <form onSubmit={this.handleSaveMission}>
          <InputFieldWhiteDark
            name="name" title="Name" symbolLimit={100} required value={name}
            placeholder="Unicoin"
            eventHandler={this.handleChangeFormData}
            errorText={errors.name} />

          <InputFieldDropdownHalfed
            name="token" title="Token" required value={token}
            selectEntries={this.props.tokens}
            eventHandler={this.handleChangeFormData}
            errorText={errors.token}
          />

          <InputFieldWhiteDark
            name="subtitle" title="Subtitle" symbolLimit={140} required value={subtitle}
            placeholder="Unicoin is the future of tokenizing fantastical beast networks"
            eventHandler={this.handleChangeFormData}
            errorText={errors.subtitle} />

          <InputFieldDescription
            name="description" title="Description" symbolLimit={250} required value={description}
            placeholder="Here will be templated text but with lower opacity as lower opacity indicates that it is a placeholder. When user start to type within field, text should have 100% opacity."
            eventHandler={this.handleChangeFormData}
            errorText={errors.description}
          />

          <InputFieldUploadFile
            name="logo" title="Mission Logo" required
            imgPreviewDimensions="150x100"
            imgPreviewUrl={logoPreview}
            eventHandler={this.handleChangeFormData}
            errorText={errors.logo} />
          <InputFieldUploadFile
            name="image" title="Mission Image" required
            imgPreviewDimensions="100x100"
            imgPreviewUrl={imagePreview}
            eventHandler={this.handleChangeFormData}
            errorText={errors.image}
          />
        </form>
      </Layout>
    </React.Fragment>
  }
}

Mission.propTypes = {
  mission: PropTypes.shape({})
}
