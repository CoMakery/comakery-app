import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'category' ];

  updateTransferFormSrc() {
    let categoryId = $(this.categoryTarget).data('categoryId');
    let transferFormSelector = $('#transfer_form');
    let path = transferFormSelector.attr('src').split('?').shift();

    transferFormSelector.attr('src', `${path}?award[transfer_type_id]=${categoryId}`);

    // Disable lazy load of transfer form to be able to send new request with different categoryId
    transferFormSelector.attr('loading', '');
  }
}
