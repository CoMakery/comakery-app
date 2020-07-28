import React from 'react'
import 'react-dates/initialize'
import 'react-dates/lib/css/_datepicker.css'
import { DateRangePicker } from 'react-dates'
import * as Turbolinks from 'turbolinks'
import moment from 'moment'

class TransfersCalendar extends React.Component {
  constructor(props) {
    super(props)

    let currentUrl = new URL(window.location.href)
    let currentStartDate = currentUrl.searchParams.get('q[created_at_gteq]')
    let currentEndDate = currentUrl.searchParams.get('q[created_at_lteq]')

    this.state = {
      focusedInput: null,
      startDate: currentStartDate && moment(currentStartDate),
      endDate: currentEndDate && moment(currentEndDate)
    }
  }

  applyFilter(startDate, endDate) {
    this.setState({ startDate, endDate })

    if (startDate && endDate) {
      let currentUrl = new URL(window.location.href)
      currentUrl.searchParams.set('q[created_at_gteq]', startDate)
      currentUrl.searchParams.set('q[created_at_lteq]', endDate)
      Turbolinks.visit(currentUrl)
    }
  }

  render() {
    return (
      <DateRangePicker
        startDate={this.state.startDate} // momentPropTypes.momentObj or null,
        startDateId='transfers_calendar_start_date_id' // PropTypes.string.isRequired,
        endDate={this.state.endDate} // momentPropTypes.momentObj or null,
        endDateId='transfers_calendar_end_date_id' // PropTypes.string.isRequired,
        onDatesChange={({ startDate, endDate }) => this.applyFilter(startDate, endDate)} // PropTypes.func.isRequired,
        focusedInput={this.state.focusedInput} // PropTypes.oneOf([START_DATE, END_DATE]) or null,
        onFocusChange={focusedInput => this.setState({ focusedInput })} // PropTypes.func.isRequired,
        noBorder
        regular
        hideKeyboardShortcutsPanel
        withPortal={false}
        startDateAriaLabel=''
        endDateAriaLabel=''
        numberOfMonths={2}
        transitionDuration={0}
        isOutsideRange={_ => false}
      />
    )
  }
}

export default TransfersCalendar
