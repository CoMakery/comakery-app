import { Controller } from 'stimulus'
import { Decimal } from 'decimal.js'

export default class extends Controller {
  static targets = [
    'amount',
    'price',
    'total'
  ]

  calculateTotalPrice() {
    this.totalTarget.textContent = Decimal.mul(
      this.amountTarget.value || 0,
      parseFloat(this.priceTarget.value || 0)
    ).toDecimalPlaces(
      2,
      Decimal.ROUND_DOWN
    ).toFixed(
      2,
      Decimal.ROUND_DOWN
    )
  }
}
