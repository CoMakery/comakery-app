import { Controller } from 'stimulus'

export default class extends Controller {
  static values = {
    accountsUrl: String
  }

  getWallets(e) {
    let accountId = e.target.value
    let src = `${this.accountsUrlValue}/${accountId}/wallets`

    document.getElementById('account_wallets').setAttribute('src', src)
  }
}
