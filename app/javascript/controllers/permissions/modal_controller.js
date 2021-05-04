import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.jmodal = this.element.jModalController;

    this.jmodal.show()
  }

  closeModal() {
    this.jmodal.hide()
  }
}
