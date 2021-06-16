import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'transferType' ];

  updateTransferFormSrc() {
    let transferTypeId = $(this.transferTypeTarget).data('transferTypeId')
    let transferFormSelector = $('#transfer_form')
    let path = transferFormSelector.attr('src').split('?').shift()

    transferFormSelector.attr('src', `${path}?award[transfer_type_id]=${transferTypeId}`)

    // Disable lazy load of transfer form to be able to send new request with different transferTypeId
    transferFormSelector.attr('loading', '')
  }
}
