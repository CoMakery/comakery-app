import { Controller } from 'stimulus'
import jQuery from 'jquery'

export default class extends Controller {
  connect() {
    this.jmodal = jQuery(this.element);
    this.jmodal.on('show.bs.modal', this.onShow.bind(this));
    this.jmodal.on('shown.bs.modal', this.onShown.bind(this));
    this.jmodal.on('hide.bs.modal', this.onHide.bind(this));
    this.jmodal.on('hidden.bs.modal', this.onHidden.bind(this));

    this.element.jModalController = this;
  }

  disconnect() {
    this.jmodal.off('show.bs.modal');
    this.jmodal.off('shown.bs.modal');
    this.jmodal.off('hide.bs.modal');
    this.jmodal.off('hidden.bs.modal');
  }

  onShow(jevent) {
    this.element.dispatchEvent(this._createEvent('modal:show', jevent));
  }

  onShown(jevent) {
    this.element.dispatchEvent(this._createEvent('modal:shown', jevent));
  }

  onHide(jevent) {
    this.element.dispatchEvent(this._createEvent('modal:hide', jevent));
  }

  onHidden(jevent) {
    this.element.dispatchEvent(this._createEvent('modal:hidden', jevent));
  }

  show() { this.jmodal.modal('show') }

  hide() { this.jmodal.modal('hide') }

  _createEvent(name, jevent) {
    const details = { relatedTarget: jevent.relatedTarget, controller: this.controller }
    return new CustomEvent(name, { detail: details });
  }
}
