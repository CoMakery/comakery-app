import { Controller } from 'stimulus';
import Rails from '@rails/ujs';

export default class extends Controller {
  static targets = ['collectionWrapper'];

  get defaultUrl() { return this.element.dataset.src }

  toggleZeroBalances(event) {
    event.preventDefault();

    this._requestCollection(event.currentTarget.getAttribute('href'));
  }

  refreshCollection(_event) {
    this._requestCollection();
  }

  _requestCollection(url=this.defaultUrl) {
    Rails.ajax({
      type: 'GET',
      url: url,
      dataType: 'json',
      success: (resp) => this.collectionWrapperTarget.innerHTML = resp.content
    })
  }
}
