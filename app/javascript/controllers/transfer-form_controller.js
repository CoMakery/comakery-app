import { Controller } from 'stimulus'
import { Decimal } from 'decimal.js'

export default class extends Controller {
  static targets = [ 'amount', 'quantity', 'total', 'form', 'create' ]

  calculateTotal() {
    this.totalTarget.textContent = Decimal.mul(
      this.amountTarget.value || 0,
      parseFloat(this.quantityTarget.value)
    ).toDecimalPlaces(
      this.decimalPlaces,
      Decimal.ROUND_DOWN
    ).toFixed(
      this.decimalPlaces,
      Decimal.ROUND_DOWN
    )
  }

  showForm() {
    this.formTarget.style.display = 'flex'
    this.createTarget.disabled = true

    this.transfers.forEach((transfer) => {
      transfer.style.opacity = 0.9
      transfer.style.pointerEvents = 'none'
    })
  }

  hideForm() {
    this.formTarget.style.display = 'none'
    this.createTarget.disabled = false

    this.transfers.forEach((transfer) => {
      transfer.style.opacity = 1
      transfer.style.pointerEvents = 'initial'
    })
  }

  get decimalPlaces() {
    return parseFloat(this.data.get('decimalPlaces'))
  }

  get transfers() {
    return document.querySelectorAll('.transfers-table__transfer:not(.transfers-table__transfer--new)')
  }
}
