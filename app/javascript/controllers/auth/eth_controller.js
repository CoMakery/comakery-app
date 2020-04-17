import EthereumController from '../ethereum_controller'

export default class extends EthereumController {
  async auth() {
    if (!await this._startDapp() || !this.nonce) {
      this._showError()
      return false
    }

    this._auth()
  }

  async _auth() {
    let signature = await this._personalSign(this.nonce)

    if (!signature) {
      this._showError()
      return false
    }

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
        }
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
    super('Unable to authenticate. Please contact support.')
  }

  get nonce() {
    if (!this.data.has('nonce')) {
      fetch(this.noncePath, {
        credentials: 'same-origin',
        method     : 'POST',
        body       : JSON.stringify({
          body: {
            data: {
              'auth_eth': {
                'public_address': this.coinBase
              }
            }
          }
        }),
        headers: {
          'Content-Type': 'application/json'
        }
      }).then(response => {
        if (response.status === 200) {
          response.json().then(r => {
            this.data.set('nonce', r.nonce)
          })
        } else {
          return false
        }
      })
    }

    return this.data.get('nonce')
  }

  get authPath() {
    return this.data.get('authPath')
  }

  get noncePath() {
    return this.data.get('noncePath')
  }
}
