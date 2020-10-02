import React from 'react'
import PropTypes from 'prop-types'
import DataField from './subcomponents/DataField'
import FormField from './subcomponents/FormField'
import SummaryTable from './subcomponents/SummaryTable'
import HistoryTable from './subcomponents/HistoryTable'
import Alert from './subcomponents/Alert'

export default class Account extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      isEdit     : false,
      isSummary  : true,
      accountData: props.currentAccount, // to show account details
      awards     : props.awards,
      projects   : props.projects,
      awardPage  : 0,
      projectPage: 0,
      ...props.currentAccount, // formData
      message    : null, // notify sucess or error after account info update
      messageType: 'notice',
      showMessage: false, // show or hide message
      errors     : {} // error hash for account form
    } // edit-ethereum or view-ethereum // summary or history view // start from 0 -> rails side starts from 1
    this.fileInput = React.createRef() // file upload
    this.dateInput = React.createRef() // dateOfBirth
    this.mounted = false

    this.handleChangeEditMode = this.handleChangeEditMode.bind(this)
    this.handleChangeTableView = this.handleChangeTableView.bind(this)
    this.handleUpdateAccountInfo = this.handleUpdateAccountInfo.bind(this)
    this.handleChangeAccountFormData = this.handleChangeAccountFormData.bind(this)
    this.handleChangeAwardPage = this.handleChangeAwardPage.bind(this)
    this.handleChangeProjectPage = this.handleChangeProjectPage.bind(this)
    this.loadDataFromServer = this.loadDataFromServer.bind(this)
  }

  componentDidMount() {
    this.mounted = true
    window.initializeAccountPage()
  }

  componentWillMount() {
    this.mounted = false
  }

  handleChangeEditMode(e) {
    e.preventDefault()
    this.setState({ isEdit: !this.state.isEdit })
  }

  handleChangeTableView() {
    this.setState({ isSummary: !this.state.isSummary })
  }

  handleUpdateAccountInfo(e) {
    e.preventDefault()
    let formData = new FormData()
    formData.append('account[email]', this.state.email || '')
    formData.append('account[first_name]', this.state.firstName || '')
    formData.append('account[last_name]', this.state.lastName || '')
    formData.append('account[nickname]', this.state.nickname || '')
    formData.append('account[date_of_birth]', this.dateInput.current.value || '')
    formData.append('account[country]', this.state.country || '')
    formData.append('account[ethereum_auth_address]', this.state.ethereumAuthAddress || '')
    formData.append('account[specialty_id]', this.state.specialtyId || '')
    formData.append('account[occupation]', this.state.occupation || '')
    formData.append('account[linkedin_url]', this.state.linkedinUrl || '')
    formData.append('account[github_url]', this.state.githubUrl || '')
    formData.append('account[dribble_url]', this.state.dribbleUrl || '')
    formData.append('account[behance_url]', this.state.behanceUrl || '')
    if (this.fileInput.current.files[0]) {
      formData.append('account[image]', this.fileInput.current.files[0])
    }

    $.ajax({
      url        : '/account',
      data       : formData,
      processData: false,
      contentType: false,
      dataType   : 'json',
      type       : 'PATCH',

      success: response => {
        this.setState({
          message    : response.message,
          messageType: 'notice',
          showMessage: true,
          isEdit     : false,
          accountData: response.currentAccount,
          errors     : {}
        })
      },

      error: (xhr) => {
        let response = xhr.responseJSON
        this.setState({
          message    : response.message,
          messageType: 'alert',
          showMessage: true,
          errors     : response.errors
        })
      }
    })
  }

  handleChangeAccountFormData(e) {
    const target = e.target
    const value = target.type === 'checkbox' ? target.checked : target.value
    const name = target.name

    this.setState({
      [name]: value
    })
  }

  handleChangeAwardPage(value) {
    this.mounted && this.setState({ awardPage: value }, () => this.loadDataFromServer())
  }

  handleChangeProjectPage(value) {
    this.mounted && this.setState({ projectPage: value }, () => this.loadDataFromServer())
  }

  loadDataFromServer() {
    $.ajax({
      url : '/account',
      data: {
        award_page  : this.state.awardPage + 1,
        project_page: this.state.projectPage + 1
      },
      dataType: 'json',
      type    : 'GET',

      success: data => {
        this.setState({ awards: data.awards, projects: data.projects })
      },

      error: (xhr, status, err) => {
        console.error(status, err.toString())
      }
    })
  }

  render() {
    const downloadWidget = (
      <div className='row'>
        <div className='columns small-12 no-h-pad'>
          <a className='download-data' href='/accounts/download_data.zip'>
            Download My Data&nbsp;
            <i className='fa fa-download' />
          </a>
        </div>
        {this.state.accountData.imageUrl &&
        <img src={this.state.accountData.imageUrl} style={{ marginTop: 10 }} />}
      </div>
    )

    const specialty = this.props.specialtyList.find(specialty => specialty[1] === this.state.specialtyId)

    return <React.Fragment>
      <Alert message={this.state.message} messageType={this.state.messageType} isVisible={this.state.showMessage} toggleVisible={() => {
        this.setState({ showMessage: !this.state.showMessage })
      }} />
      <div className='m-t-10'>
        <div className={`${this.state.isEdit ? '' : 'hide'} edit-ethereum-wallet`}>
          <h4 style={{ border: 'none' }}>
            Account Details (
            <a href='#' onClick={this.handleChangeEditMode}>
              Cancel
            </a>
            )
          </h4>
          <div className='row'>
            <form onSubmit={this.handleUpdateAccountInfo}>
              <FormField fieldLabel='Email' fieldName='email' fieldValue={this.state.email} handleChange={this.handleChangeAccountFormData} error={this.state.errors.email} />
              <FormField fieldLabel='First Name' fieldName='firstName' fieldValue={this.state.firstName} handleChange={this.handleChangeAccountFormData} error={this.state.errors.firstName} />
              <FormField fieldLabel='Last Name' fieldName='lastName' fieldValue={this.state.lastName} handleChange={this.handleChangeAccountFormData} error={this.state.errors.lastName} />
              <FormField fieldLabel='Nickname' fieldName='nickname' fieldValue={this.state.nickname} handleChange={this.handleChangeAccountFormData} error={this.state.errors.nickname} />
              <FormField fieldLabel='Ethereum Auth Address' fieldName='ethereumAuthAddress' fieldValue={this.state.ethereumAuthAddress} handleChange={this.handleChangeAccountFormData} error={this.state.errors.ethereumAuthAddress} />
              <div className='columns small-3'>
                <label>Date of Birth</label>
              </div>
              <div className={`columns small-9 ${this.state.errors.dateOfBirth ? 'error' : ''}`}>
                <input type='text' className='datepicker' placeholder='mm/dd/yyyy' name='dateOfBirth' defaultValue={this.state.dateOfBirth || ''} ref={this.dateInput} />
                {this.state.errors.dateOfBirth && <small className='error'>
                  {this.state.errors.dateOfBirth}
                </small>}
              </div>
              <div className='columns small-3'>
                <label>Country</label>
              </div>
              <div className={`columns small-9 ${this.state.errors.country ? 'error' : ''}`}>
                <select name='country' value={this.state.country || ''} onChange={this.handleChangeAccountFormData}>
                  <option value=''>Select Country</option>
                  {this.props.countryList.map(country =>
                    <option key={country} value={country}>
                      {country}
                    </option>
                  )}
                </select>
                {this.state.errors.country && <small className='error'>
                  {this.state.errors.country}
                </small>}
              </div>

              <div className='columns small-3'>
                <label>My Specialty</label>
              </div>
              <div className={`columns small-9 ${this.state.errors.specialty ? 'error' : ''}`}>
                <select name='specialtyId' value={this.state.specialtyId || ''} onChange={this.handleChangeAccountFormData}>
                  <option value=''>Please Select One</option>
                  {this.props.specialtyList.map(specialty =>
                    <option key={specialty[0]} value={specialty[1]}>
                      {specialty[0]}
                    </option>
                  )}
                </select>
                {this.state.errors.country && <small className='error'>
                  {this.state.errors.country}
                </small>}
              </div>

              <FormField fieldLabel='Occupation' fieldName='occupation' fieldValue={this.state.occupation} handleChange={this.handleChangeAccountFormData} error={this.state.errors.occupation} />

              <FormField fieldLabel='LinkedIn Profile URL' fieldName='linkedinUrl' fieldValue={this.state.linkedinUrl} handleChange={this.handleChangeAccountFormData} error={this.state.errors.linkedinUrl} />

              <FormField fieldLabel='GitHub Profile URL' fieldName='githubUrl' fieldValue={this.state.githubUrl} handleChange={this.handleChangeAccountFormData} error={this.state.errors.githubUrl} />

              <FormField fieldLabel='Dribbble Profile URL' fieldName='dribbleUrl' fieldValue={this.state.dribbleUrl} handleChange={this.handleChangeAccountFormData} error={this.state.errors.dribbleUrl} />

              <FormField fieldLabel='Behance Profile URL' fieldName='behanceUrl' fieldValue={this.state.behanceUrl} handleChange={this.handleChangeAccountFormData} error={this.state.errors.behanceUrl} />

              <div className='columns small-3'>
                <label>Image</label>
              </div>
              <div className='columns small-9'>
                <input type='file' name='image' accept='image/*' ref={this.fileInput} />
              </div>
              <div className='columns small-12 text-right'>
                <input type='submit' value='Save' className='button' />
              </div>
            </form>
          </div>
        </div>
        <div className={`${this.state.isEdit ? 'hide' : ''} view-ethereum-wallet`}>
          <div className='columns medium-12 large-9 no-h-pad'>
            <h4 style={{ border: 'none' }}>
              Account Details&nbsp;
              <a href='#' onClick={this.handleChangeEditMode}>
                <i className='fa fa-cog' />
              </a>
            </h4>
            <h5><a href='/wallets'>Wallets →</a></h5>
            <DataField fieldName='Email' fieldValue={this.state.accountData.email} />
            <DataField fieldName='First Name' fieldValue={this.state.accountData.firstName} />
            <DataField fieldName='Last Name' fieldValue={this.state.accountData.lastName} />
            <DataField fieldName='Nickname' fieldValue={this.state.accountData.nickname} />
            <DataField fieldName='Ethereum Auth Address' fieldValue={this.state.ethereumAuthAddress} />
            <DataField fieldName='Date of Birth' fieldValue={this.state.accountData.dateOfBirth} />
            <DataField fieldName='Country' fieldValue={this.state.accountData.country} />
            <DataField fieldName='My Specialty' fieldValue={specialty ? specialty[0] : ''} />
            <DataField fieldName='Occupation' fieldValue={this.state.occupation} />
            <DataField fieldName='LinkedIn Profile URL' fieldValue={this.state.linkedinUrl} />
            <DataField fieldName='GitHub Profile URL' fieldValue={this.state.githubUrl} />
            <DataField fieldName='Dribbble Profile URL' fieldValue={this.state.dribbleUrl} />
            <DataField fieldName='Behance Profile URL' fieldValue={this.state.behanceUrl} />
          </div>
          <div className='columns show-for-large medium-12 large-3 text-right'>
            {downloadWidget}
          </div>
          <div className='columns hide-for-large medium-12' style={{ marginBottom: 20 }}>
            {downloadWidget}
          </div>
        </div>
      </div>
      <div className='columns medium-12 no-h-pad'>
        <div style={{ float: 'left', width: 90 }}>
          <label>
            <input type='radio' checked={this.state.isSummary} onChange={this.handleChangeTableView} />
            Summary
          </label>
        </div>
        <div style={{ float: 'left', width: 90 }}>
          <label>
            <input type='radio' checked={!this.state.isSummary} onChange={this.handleChangeTableView} />
            History
          </label>
        </div>
      </div>
      {this.state.isSummary ? <SummaryTable projects={this.state.projects} currentPage={this.state.projectPage} pageCount={Math.ceil(this.props.projectsCount / 20)} handlePageChange={this.handleChangeProjectPage} /> : <HistoryTable awards={this.state.awards} currentPage={this.state.awardPage} pageCount={Math.ceil(this.props.awardsCount / 20)} handlePageChange={this.handleChangeAwardPage} />}
    </React.Fragment>
  }
}

Account.propTypes = {
  currentAccount: PropTypes.shape({}).isRequired,
  awards        : PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  awardsCount   : PropTypes.number.isRequired,
  projects      : PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  projectsCount : PropTypes.number.isRequired,
  countryList   : PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  specialtyList : PropTypes.arrayOf(PropTypes.array).isRequired,
  clippyIcon    : PropTypes.string.isRequired
}
