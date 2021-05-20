import { Controller } from 'stimulus';
import Rails from '@rails/ujs';
import PubSub from 'pubsub-js'
import { FLASH_ADD_MESSAGE } from "../../src/javascripts/eventTypes";

export default class extends Controller {
  static targets = ['submit'];

  connect() {
    this.updatedEvent = new CustomEvent('batch-size:updated', { bubbles: true });

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
        this.element.dispatchEvent(this.updatedEvent);
      },
      error: (response, status) => {
        if (status === 'Unauthorized') {
          this._addFlashMessage('error', 'You are not authorized to perform this action')
        }

        if (response.errors) {
          this._addErrors(response.errors)
        }
      }
    });
  }

  _addErrors(errors) {
    let $errorsContainer = $('#project_batch_size_modal ul.errors');

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
