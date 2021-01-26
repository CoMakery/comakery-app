import { Controller } from 'stimulus';
import Rails from '@rails/ujs';

export default class extends Controller {
  static targets = ['modalContent'];

  connect() {
    this.jmodal = this.element.jModalController;
  }

  loadContent(event) {
    Rails.ajax({
      type: 'GET',
      url: event.detail.relatedTarget.dataset.src,
      dataType: 'json',
      success: (resp) => { this.modalContentTarget.innerHTML = resp.content }
    })
  }

  closeModal() { this.jmodal.hide() }

  removeContent(_event) {
    this.modalContentTarget.innerHTML = '';
  }
}
