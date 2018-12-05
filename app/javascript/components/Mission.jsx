import React from 'react'
import PropTypes from 'prop-types'
import { FormLabel } from './subcomponents/FormLabel'
import Alert from './subcomponents/Alert'

export default class Mission extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      ...props,
      logo       : null,
      image      : null,
      message    : null, // notify sucess or error after account info update
      messageType: 'notice',
      showMessage: false, // show or hide message
      errors     : {}, // error hash for account form
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
    const target = e.target
    const value = target.type === 'checkbox' ? target.checked : target.value
    const name = target.name
    console.log(value)
    this.setState({
      [name]: value,
    })
  };

  handleImageChange = e => {
    e.preventDefault()

    let reader = new FileReader()
    let file = e.target.files[0]
    const name = e.target.name

    reader.onloadend = () => {
      this.setState({
        [name]            : file,
        [name + 'Preview']: reader.result
      })
    }

    reader.readAsDataURL(file)
  }

  handleSaveMission = e => {
    e.preventDefault()
    let formData = new FormData()
    const {name, subtitle, description, logo, image} = this.state
    formData.append('mission[name]', name)
    formData.append('mission[subtitle]', subtitle)
    formData.append('mission[description]', description)
    if (logo) {
      formData.append('mission[logo]', logo)
    }
    if (image) {
      formData.append('mission[image]', image)
    }

    // check if it's update or create
    let url = '/missions'
    if (this.props.id) {
      url = '/missions/' + this.props.id
    }

    $.ajax({
      url        : url,
      data       : formData,
      processData: false,
      contentType: false,
      dataType   : 'json',
      type       : this.props.id ? 'PATCH' : 'POST',

      success: response => {
        console.log('success')
      },

      error: (xhr) => {
        let response = xhr.responseJSON
        this.setState({
          message    : response.message,
          messageType: 'alert',
          showMessage: true,
          errors     : response.errors,
        })
        console.log('error')
        console.log(xhr.responseJSON)
      },
    })
  }

  render() {
    console.log(this.state)
    const {id, name, subtitle, description, logoPreview, imagePreview, message, messageType, showMessage, errors} = this.state
    return <React.Fragment>
      <Alert message={message} messageType={messageType} isVisible={showMessage} toggleVisible={() => {
        this.setState({ showMessage: !showMessage })
      }} />

      <form onSubmit={this.handleSaveMission}>
        <div className="mission-container">
          <div className="mission-header">{id ? 'Edit Mission' : 'Create a New Mission'}</div>
          <div className="row">
            <div className="columns large-6 medium-12">
              <FormLabel title="Name" required length={100} currentLength={name.length} />
              <input className="mission-input" type="text" name="name" placeholder="Unicoin" maxLength="100" value={name} onChange={this.handleChangeFormData} />
              {errors.name && <small className="error">{errors.name}</small>}

              <FormLabel title="Subtitle" required length={140} currentLength={subtitle.length} />
              <input className="mission-input" type="text" name="subtitle" placeholder="Unicoin is the future of tokenizing fantastical beast networks" maxLength="140" value={subtitle} onChange={this.handleChangeFormData} />
              {errors.subtitle && <small className="error">{errors.subtitle}</small>}

              <FormLabel title="Description" required length={250} currentLength={description.length} />
              <textarea className="mission-input mission-input--multi" type="text" name="description" placeholder="Here will be templated text but with lower opacity as lower opacity indicates that it is a placeholder. When user start to type within field, text should have 100% opacity." maxLength="250" value={description} onChange={this.handleChangeFormData} />
              {errors.description && <small className="error">{errors.description}</small>}

              <div className="mission-image-container">
                <div className="mission-image-container__half">
                  <FormLabel title="Mission Logo" required />
                  <img src={logoPreview} width={150} height={100} />
                  <input id="mission_logo" type="file" name="logo" onChange={this.handleImageChange} style={{display: 'none'}} />
                  <div className="mission-choose-file">
                    <label htmlFor="mission_logo" className="mission-input mission-input--file">
                      Choose file
                    </label>
                    <div className="img-resolution">Image should be <br />1200px x 800px</div>
                  </div>
                  {errors.logo && <small className="error">{errors.logo}</small>}
                </div>
                <div className="mission-image-container__half">
                  <FormLabel title="Mission Image" required />
                  <img src={imagePreview} width={100} height={100} />
                  <input id="mission_image" type="file" name="image" onChange={this.handleImageChange} style={{display: 'none'}} />
                  <div className="mission-choose-file">
                    <label htmlFor="mission_image" className="mission-input mission-input--file">
                      Choose file
                    </label>
                    <div className="img-resolution">Image should be <br />800px x 800px</div>
                  </div>
                  {errors.image && <small className="error">{errors.image}</small>}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="mission-footer">
          <button className="mission-footer__save">{id ? 'Update' : 'Save'}</button>
        </div>
      </form>
    </React.Fragment>
  }
}

Mission.propTypes = {
  mission: PropTypes.shape({})
}
