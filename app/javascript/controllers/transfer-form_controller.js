import { Controller } from 'stimulus'
import { Decimal } from 'decimal.js'
import { Turbo } from '@hotwired/turbo-rails'
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

    let url = this.createTarget[this.createTarget.length - 1].dataset.url
    let transfer = this.targets.find('create').value

    if (transfer === 'Manage Categories') {
      Turbo.visit(url)
    }    else if (transfer === '') {
      this.formChildTarget.style.display = 'none'
    }    else {
      let category = this.formChildTarget.getElementsByClassName('transfers-table__transfer__name')
      category[0].childNodes[3].value = transfer
    }

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
