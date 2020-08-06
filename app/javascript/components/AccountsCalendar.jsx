import React from 'react'
import 'react-dates/initialize'
import 'react-dates/lib/css/_datepicker.css'
import { SingleDatePicker } from 'react-dates'
import * as Turbolinks from 'turbolinks'
import moment from 'moment'

class AccountsCalendar extends React.Component {
  constructor(props) {
    super(props)

    let currentUrl = new URL(window.location.href)
    let currentDate = currentUrl.searchParams.get('q[account_token_records_lockup_until_lt]')

    this.state = {
      focusedInput: null,
      startDate: currentDate && moment(currentDate)
    }
  }

  applyFilter(startDate) {
    this.setState({ startDate })

    if (startDate) {
      let currentUrl = new URL(window.location.href)
      currentUrl.searchParams.set('q[account_token_records_lockup_until_lt]', startDate)
      currentUrl.searchParams.set('q[account_token_records_token_id_eq]', this.props.projectTokenId)
      Turbolinks.visit(currentUrl)
    }
  }

  render() {
    return (
      <SingleDatePicker
        date={this.state.startDate} // momentPropTypes.momentObj or null
        onDateChange={startDate => this.applyFilter(startDate)} // PropTypes.func.isRequired
        focused={this.state.focused} // PropTypes.bool
        onFocusChange={({ focused }) => this.setState({ focused })} // PropTypes.func.isRequired
        id='accounts_calendar_start_date_id' // PropTypes.string.isRequired,
        noBorder
        regular
        hideKeyboardShortcutsPanel
        withPortal={false}
        numberOfMonths={2}
        transitionDuration={0}
        isOutsideRange={_ => false}
      />
    )
  }
}

export default AccountsCalendar
