import { Controller } from 'stimulus'

export default class extends Controller {
  initialize() {
    this.addTurboStreamHeaders = this.addTurboStreamHeaders.bind(this)
  }

  connect() {
    this.element.addEventListener(
      'turbo:before-fetch-request',
      this.addTurboStreamHeaders
    )
  }

  disconnect() {
    document.removeEventListener(
      'turbo:before-fetch-request',
      this.addTurboStreamHeaders
    )
  }

  addTurboStreamHeaders(event) {
    const { headers } = event.detail.fetchOptions || {}

    if (headers) {
      headers.Accept = ['text/vnd.turbo-stream.html', headers.Accept].join(', ')
    }
  }
}
