import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['source', 'icon'];

  get isSourceInput() {
    return ['textarea', 'input'].includes(this.sourceTarget.tagName.toLowerCase())
  }
  get content() {
    return this.isSourceInput ?
      this.sourceTarget.value :
      this.sourceTarget.textContent
  }

  copy() {
    navigator.clipboard
      .writeText(this.content)
      .then(this.gotCopied.bind(this));
  }

  gotCopied() {
    if (!this.hasIconTarget) return

    setTimeout(this.cleanAnimation.bind(this), 500);
    this.startAnimation();
  }

  startAnimation() {
    this.iconTarget.classList.remove('far');
    this.iconTarget.classList.add('fas', 'animate', 'bounceIn');
  }

  cleanAnimation() {
    this.iconTarget.classList.remove('fas', 'animate', 'bounceIn')
    this.iconTarget.classList.add('far');
  }
}
