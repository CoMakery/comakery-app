import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.element.style.whiteSpace   = 'nowrap';
    this.element.style.overflow     = 'hidden';
    this.element.style.textOverflow = 'ellipsis';
    this.element.style.width        = `${this.width}px`;
  }

  get width() { return this.element.dataset.width }
}
