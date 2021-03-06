import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.jmodal = this.element.jModalController;
  }

  closeModal() {
    this.jmodal.hide();
    this.jmodal.reset();
  }
}
