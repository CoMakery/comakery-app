import { Controller } from 'stimulus'
import Rails from '@rails/ujs'

export default class extends Controller {
  static targets = [ 'hotWalletMode' ]

  toggle() {
    const formData = new FormData()
    const mode = this.hotWalletModeTarget.value
    formData.append('project[hot_wallet_mode]', mode)

    fetch(this.data.get('update-url'), {
      body: formData,
      method: 'PATCH',
      credentials: 'include',
      headers: { 'X-CSRF_Token': Rails.csrfToken() }
    })
  }
}
