import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  fetchStream() {
    const url = this.data.get('url')

    fetch(url, {
      headers: {
        Accept: 'text/vnd.turbo-stream.html'
      }
    }).then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

  headers(event) {
    const { headers } = event.detail.fetchOptions || {}

    if (headers) {
      headers.Accept = ['text/vnd.turbo-stream.html', headers.Accept].join(', ')
    }
  }
}
