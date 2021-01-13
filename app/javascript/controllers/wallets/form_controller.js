import { Controller } from 'stimulus';
import Rails from '@rails/ujs';
import { FLASH_ADD_MESSAGE } from '../../src/javascripts/eventTypes'
import PubSub from 'pubsub-js'

export default class extends Controller {
  static targets = ['submit'];

  connect() {
    this.createdEvent = new CustomEvent('wallets:created', { bubbles: true });
    this._checkFormValidity();
  }

  inputChanged(event) {
    this._validateInput(event.target);
    this._checkFormValidity();
  }

  onSubmit(event) {
    event.preventDefault();

    Rails.ajax({
      type: this.element.attributes.method.value,
      url: this.element.attributes.action.value,
      data: new FormData(this.element),
      success: (resp) => {
        this._addFlashMessage('notice', resp.message);
        this.element.dispatchEvent(this.createdEvent);
      },
      error: (resp) => this._addFlashMessage('error', resp.message),
    });
  }

  _validateInput(input) {
    if (input.checkValidity()) {
      input.classList.remove('is-invalid');
      const nextSibling = input.nextElementSibling;
      nextSibling && nextSibling.classList.contains('invalid-feedback') && nextSibling.remove();
    } else {
      input.classList.add('is-invalid');
      input.insertAdjacentHTML(
        'afterend',
        '<div class="invalid-feedback">Can not be blank</div>'
      );
    }
  }

  _checkFormValidity() {
    this.submitTarget.disabled = !this.element.checkValidity();
  }

  _addFlashMessage(severity, text) {
    PubSub.publish(FLASH_ADD_MESSAGE, { severity, text })
  }
}
