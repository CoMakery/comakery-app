import React from 'react'
import Layout from './../layouts/Layout'
import ButtonBorder from './ButtonBorder'
import ButtonPrimaryDisabled from './ButtonPrimaryDisabled'
import ButtonPrimaryEnabled from './ButtonPrimaryEnabled'
import InputFieldDescription from './InputFieldDescription'
import InputFieldDescriptionMiddle from './InputFieldDescriptionMiddle'
import InputFieldHalfed from './InputFieldHalfed'
import InputFieldWhiteDark from './InputFieldWhiteDark'
import InputFieldDefined from './InputFieldDefined'
import InputFieldDropdown from './InputFieldDropdown'
import InputFieldDropdownHalfed from './InputFieldDropdownHalfed'
import Checkbox from './Checkbox'
import InputFieldUploadFile from './InputFieldUploadFile'
import Icon from './Icon'
import MessageError from './MessageError'
import MessageWarning from './MessageWarning'

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
        <Layout
          className="styleguide-index"
          title="layout with sidebar"
          hasBackButton={false}
          hasSubFooter
          sidebar={
            <div>Responsive Sidebar Placeholder</div>
          }
        >
          <InputFieldWhiteDark
            name="input[text1]"
            value={this.state['input[text1]']}
            eventHandler={this.handleInputChange}
            symbolLimit={0}
          />
          <InputFieldWhiteDark
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

          <Icon />
          <Icon width={100} height={100} className="styleguide-index--icon" />
          {[
            'Atoms---Icons-System--Search-2.png',
            'Atoms---Icons-System-World.png',
            'Atoms---Decoration---Dot.png',
            'ICON-BATCH-GRAY-2.png',
            'ICON-TOKENS-BTC.png',
            'Atoms---Icons-System-Instagram-2.png',
            'Atoms---Icons-System-Camera.png',
            'ICON-BATCH-PURPLE.png',
            'CHARACTERS-COUNTER-VISIBLE.png',
            'ICON-BATCH-PURPLE-3.png',
            'ICON-DROP_DOWN-PURPLE.png',
            'ICON-PHASE.png',
            'ICON-TOKENS-COINS.png',
            'Atoms---Icons-System-apple.png',
            'ICON-CLOSE.png',
            'Atoms---Icons-lined-arrow-right.png',
            'Atoms---Icons---System---Phone.png',
            'ICON-CLOSE-Copy.png',
            'Atoms---Icons-System-android2.png',
            'Atoms---Icons-System-Lock.png',
            'Atoms---Icons-System-Heart.png',
            'Atoms---Icon-System-Arrow---.png',
            'ICON-BATCH-GRAY.png',
            'ICON-LOCKED.png',
            'ICON-TASK.png',
            'Atoms---Icons-System-Facebook-2.png',
            'ICON-DROP_DOWN.png',
            'Atoms---Icons-System-Free-Shipping.png',
            'ICON-MISSION.png',
            'ICON-BATCH-PURPLE-2.png',
            'ICON-THREE_DOTS.png',
            'Atoms---Icons-System-windows.png',
            'Atoms---Icons-System-Twitter-2.png',
            'ICON-DONE.png',
            'Atoms---Icons-System-Play.png',
            'ICON-TASKS.png',
            'Atoms---Icons---System---Arrow.png',
            'Atoms---Icons-System-Home.png',
            'ICON-BACK.png',
            'Atoms---icons---System---chat.png',
            'ICON-BATCH.png',
            'ICON-EDIT.png',
            'ICON-BATCH-2.png',
            'Atoms---Icons-System-arrow.png',
            'Atoms---Icons-lined-arrow-right-2.png',
            'CHARACTERS-COUNTER-HIDDEN.png',
            'Atoms---Icon-System-Arrow----2.png',
            'ICON-DROP_DOWN-Copy.png',
            'ICON-TRASH.png',
            'Atoms---Icons-System--Search.png'
          ].map(i =>
            <Icon key={i} name={i} className="styleguide-index--icon" />
          )}

          <MessageError
            text="Please confirm your  email address to continue"
            className="styleguide-index--message"
          />
          <MessageWarning
            text="Please confirm your  email address to continue"
            className="styleguide-index--message"
          />

          <ButtonBorder className="styleguide-index--button" />
          <ButtonPrimaryDisabled className="styleguide-index--button" />
          <ButtonPrimaryEnabled className="styleguide-index--button" />
        </Layout>
      </React.Fragment>
    )
  }
}

export default Index
