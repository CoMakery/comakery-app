import { Controller } from 'stimulus'
import Rails from '@rails/ujs'

export default class extends Controller {
  // static targets = [ 'hotWalletMode' ]

  showModalForm() {
    console.log('Show modal form!!!')

    const modalURL = '/projects/18/show_batch_size_form'

    fetch(modalURL, {
      method: 'GET',
      credentials: 'include',
      headers: {
        'X-CSRF_Token': Rails.csrfToken(),
        'Accept': 'text/vnd.turbo-stream.html'
      }
    }) // .then(responce => console.log(responce.body.ht))
  }
}
