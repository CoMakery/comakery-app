import { Controller } from 'stimulus';
import Rails from '@rails/ujs';
import PubSub from 'pubsub-js'
import {FLASH_ADD_MESSAGE} from "../../src/javascripts/eventTypes";

export default class extends Controller {
  static targets = ['submit'];

  connect() {
    this.createdEvent = new CustomEvent('permissions:updated', { bubbles: true });

    this.jmodal = this.element.jModalController;
  }

  onSubmit(event) {
    event.preventDefault();

    Rails.ajax({
      type: this.element.attributes.method.value,
      url: this.element.attributes.action.value,
      data: new FormData(this.element),
      success: (response) => {
        this._addFlashMessage('notice', response.message)
        this.element.dispatchEvent(this.createdEvent);
      },
      error: (response) => {
        this._addErrors(response.errors)
      }
    });
  }

  _addErrors(errors) {
    let $errorsContainer = $('#accountPermissionModal ul.errors');

    $errorsContainer.html('');

    errors.forEach((error) => {
      $errorsContainer.append($('<li style="list-style-type: none;"/>').html(error));
      $errorsContainer.addClass('alert');
    })
  }

  _addFlashMessage(severity, text) {
    PubSub.publish(FLASH_ADD_MESSAGE, { severity, text })
  }
}
