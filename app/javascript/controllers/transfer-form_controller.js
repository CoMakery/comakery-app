import { Controller } from 'stimulus'
import { Decimal } from 'decimal.js'

export default class extends Controller {
  static targets = [ 'amount', 'quantity', 'total', 'form', 'formChild', 'create' ]

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
    this.formChildTarget.style.display = 'flex'
    this.createTarget.disabled = true

    this.transfers.forEach((transfer) => {
      transfer.style.opacity = 0.9
      transfer.style.pointerEvents = 'none'
    })
  }

  hideForm() {
    this.formChildTarget.style.display = 'none'
    this.formTarget.reset()
    this.createTarget.disabled = false

    this.transfers.forEach((transfer) => {
      transfer.style.opacity = 1
      transfer.style.pointerEvents = 'initial'
    })
  }

  get decimalPlaces() {
    return new Decimal(this.data.get('decimalPlaces')).toNumber()
  }

  get transfers() {
    return document.querySelectorAll('.transfers-table__transfer:not(.transfers-table__transfer--new)')
  }
}
