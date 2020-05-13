import EthereumController from './ethereum_controller'

export default class extends EthereumController {
  async auth(e) {
    e.preventDefault()

    await this._startDapp()
    await this._init()
  }

  async _init() {
    let url = `${this.noncePath}?body%5Bdata%5D%5Bauth_eth%5D%5Bpublic_address%5D=${this.coinBase}`

    fetch(url, {
      credentials: 'same-origin',
      method     : 'GET',
      headers    : {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        response.json().then(r => {
          this._personalSign(r.nonce, this._auth.bind(this))
        })
      } else {
        this._showError()
        return false
      }
    })
  }

  async _auth(signature) {
    fetch(this.authPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        body: {
          data: {
            'auth_eth': {
              'public_address': this.coinBase,
              'signature'     : signature
            }
          }
        },
        'authenticity_token': this.csrfToken
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.redirected) {
        window.location.href = response.url
      } else {
        this._showError()
      }
    })
  }

  _showError() {
    super._showError('Unable to authenticate. Please contact support.')
  }

  get authPath() {
    return this.data.get('authPath')
  }

  get noncePath() {
    return this.data.get('noncePath')
  }

  get csrfToken() {
    return this.data.get('csrfToken')
  }
}
