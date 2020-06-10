import ComakerySecurityTokenController from './comakery-security-token_controller'

export default class extends ComakerySecurityTokenController {
  static targets = [ 'form', 'button', 'ruleFromGroupId', 'ruleToGroupId', 'ruleLockupUntil', 'inputs' ]

  async create() {
    if (this._setData()) {
      this._disableEditing()
      await this._initialize()
      this._createTransferRule()
    }
  }

  async delete() {
    this.data.set('ruleLockupUntil', 0) 
    await this._initialize()
    this._createTransferRule()
  }

  _createTransferRule() {
    fetch(this.transferRulesPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        body: {
          data: {
            transfer_rule: {
              'sending_group_id': this.data.get('ruleFromGroupId'),
              'receiving_group_id': this.data.get('ruleToGroupId'),
              'lockup_until': this.data.get('ruleLockupUntil')
            }
          }
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 201) {
        response.json().then(r => {
          this.data.set('type', 'TransferRule')
          this.data.set('id', r.id)
          this._createTransaction('setAllowGroupTransfer')
        })
      } else {
        this._showError('Unable to create transfer rule. Please contact support.')
      }
    })
  }

  _setData() {
    if (Number.isNaN((new Date(this.ruleLockupUntilTarget.value).getTime()))) {
      this._showError('Allowed After Date field is required')
      return false
    } else {
      this.data.set('ruleFromGroupId', parseInt(this.ruleFromGroupIdTarget.value|| 0))
      this.data.set('ruleToGroupId', parseInt(this.ruleToGroupIdTarget.value || 0))
      this.data.set('ruleFromGroupBlockchainId', parseInt(this.ruleFromGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
      this.data.set('ruleToGroupBlockchainId', parseInt(this.ruleToGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
      this.data.set('ruleLockupUntil', (new Date(this.ruleLockupUntilTarget.value).getTime() / 1000) || 0)
      return true
    }
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

  showForm() {
    this.formTarget.classList.remove('hidden')
    this.formTarget.classList.add('transfer-rule-form--active')
  }

  hideForm() {
    this.formTarget.classList.add('hidden')
    this.formTarget.reset()
    this.formTarget.classList.remove('transfer-rule-form--active')
  }

  get transferRulesPath() {
    return this.data.get('transferRulesPath')
  }
}
