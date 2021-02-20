import ComakerySecurityTokenController from './comakery-security-token_controller'

export default class extends ComakerySecurityTokenController {
  static targets = [ 'form', 'button', 'inputs', 'outputs', 'addressMaxBalance', 'addressLockupUntil', 'addressGroupId', 'addressFrozen' ]

  async save() {
    this._disableEditing()
    this._setData()
    await this._initialize()
    this._createAccountTokenRecord()
  }

  _createAccountTokenRecord() {
    fetch(this.accountTokenRecordsPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        account_token_record: {
          'max_balance'   : this.data.get('addressMaxBalance'),
          'lockup_until'  : this.data.get('addressLockupUntil'),
          'reg_group_id'  : this.data.get('addressGroupId'),
          'account_frozen': this.data.get('addressFrozen'),
          'account_id'    : this.data.get('accountId')
        }
      }),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    }).then(response => {
      if (response.status === 201) {
        response.json().then(r => {
          this.data.set('id', r.id)
          this.data.set('type', 'AccountTokenRecord')
          this._createTransaction('setAddressPermissions')
        })
      } else {
        this._showError('Unable to create account token record. Please contact support.')
      }
    })
  }

  _setData() {
    this.data.set('addressGroupId', parseInt(this.addressGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
    this.data.set('addressLockupUntil', (new Date(this.addressLockupUntilTarget.value).getTime() / 1000) || 0)
    this.data.set('addressMaxBalance', this.addressMaxBalanceTarget.value || 0)
    this.data.set('addressFrozen', this.addressFrozenTarget.value)
  }

  _disableEditing() {
    this.inputsTargets.forEach((e) => {
      e.readOnly = true
      e.style.pointerEvents = 'none'
    })
  }

  _enableEditing() {
    this.inputsTargets.forEach((e) => {
      e.readOnly = false
      e.style.pointerEvents = null
    })
  }

  _markButtonAsPending() {
    this.buttonTarget.parentElement.classList.add('in-progress--metamask__paid')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'processing'

    this.formTarget.requestSubmit()
  }

  get accountTokenRecordsPath() {
    return this.data.get('accountTokenRecordsPath')
  }
}
