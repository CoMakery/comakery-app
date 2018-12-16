import React from 'react'
import Button from './Button'
import ButtonBorder from './ButtonBorder'
import ButtonPrimaryDisabled from './ButtonPrimaryDisabled'
import ButtonPrimaryEnabled from './ButtonPrimaryEnabled'
import InputField from './InputField'
import InputFieldDescription from './InputFieldDescription'
import InputFieldDescriptionMiddle from './InputFieldDescriptionMiddle'
import InputFieldHalfed from './InputFieldHalfed'
import InputFieldWhiteDark from './InputFieldWhiteDark'
import InputFieldDefined from './InputFieldDefined'
import InputFieldDropdown from './InputFieldDropdown'
import InputFieldDropdownHalfed from './InputFieldDropdownHalfed'
import Checkbox from './Checkbox'
import InputFieldUploadFile from './InputFieldUploadFile'

class Index extends React.Component {
  constructor(props) {
    super(props)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.state = {
      'input[text1]'    : '',
      'input[text2]'    : '',
      'input[text3]'    : '',
      'input[text4]'    : '',
      'input[text5]'    : '',
      'input[text6]'    : '',
      'input[select1]'  : 'loggedIn',
      'input[select2]'  : 'all',
      'input[checkbox1]': true,
      'input[checkbox2]': false,
      logoLocalUrl      : null
    }
  }

  handleInputChange(event) {
    this.setState({
      [event.target.name]: event.target.type === 'checkbox' ? event.target.checked : event.target.value
    })
  }

  render() {
    return (
      <React.Fragment>
        <div className="styleguide-index">
          <div className="Header-Style">
            Pages#styleguide
          </div>
          <InputField
            name="input[text1]"
            value={this.state['input[text1]']}
            eventHandler={this.handleInputChange}
          />
          <InputField
            name="input[text2]"
            value={this.state['input[text2]']}
            eventHandler={this.handleInputChange}
            errorText="Here goes error text"
          />
          <InputFieldWhiteDark
            required
            name="input[text3]"
            value={this.state['input[text3]']}
            eventHandler={this.handleInputChange}
          />
          <InputFieldHalfed
            name="input[text4]"
            value={this.state['input[text4]']}
            eventHandler={this.handleInputChange}
          />
          <InputFieldDescription
            name="input[text5]"
            value={this.state['input[text5]']}
            eventHandler={this.handleInputChange}
          />
          <InputFieldDescriptionMiddle
            name="input[text6]"
            value={this.state['input[text6]']}
            eventHandler={this.handleInputChange}
          />
          <InputFieldDefined
            value="Logged in team members"
          />
          <InputFieldDropdown
            title="Project visibility"
            selectEntries={[
              ['All team members', 'all'],
              ['Logged in team members', 'loggedIn']
            ]}
            name="input[select1]"
            value={this.state['input[select1]']}
            eventHandler={this.handleInputChange}
          />
          <InputFieldDropdownHalfed
            selectEntries={[
              ['All team members', 'all'],
              ['Logged in team members', 'loggedIn']
            ]}
            name="input[select2]"
            value={this.state['input[select2]']}
            eventHandler={this.handleInputChange}
          />
          <Checkbox
            name="input[checkbox1]"
            checked={this.state['input[checkbox1]']}
            eventHandler={this.handleInputChange}
          />
          <Checkbox
            name="input[checkbox2]"
            checked={this.state['input[checkbox2]']}
            eventHandler={this.handleInputChange}
            checkboxText="Name of the skill"
          />
          <InputFieldUploadFile title="Upload diagram screenshot" />
          <Button />
          <ButtonBorder />
          <ButtonPrimaryDisabled />
          <ButtonPrimaryEnabled />
        </div>
      </React.Fragment>
    )
  }
}

export default Index
