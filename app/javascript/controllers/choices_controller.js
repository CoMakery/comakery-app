import { Controller } from 'stimulus'
import Choices from 'choices.js'

export default class extends Controller {
  static targets = [ 'select' ]
  static values = {
    searchEnabled: Boolean,
    remoteSearchEnabled: Boolean,
    remoteSearchUrl: String,
    noChoicesText: String
  }

  connect() {
    let choices = new Choices(this.selectTarget, {
      classNames: {
        containerInner: this.selectTarget.className,
        input: 'form-control',
        inputCloned: 'form-control-sm',
        listDropdown: 'dropdown-menu',
        itemChoice: 'dropdown-item',
        activeState: 'show',
        selectedState: 'active'
      },
      searchEnabled: this.searchEnabledValue,
      searchChoices: !this.remoteSearchEnabledValue,
      shouldSort: false,
      searchResultLimit: 10,
      noChoicesText: this.noChoicesTextValue,
      noResultsText: '',
      loadingText: '',
      callbackOnCreateTemplates: function(template) {
        let itemSelectText = this.config.itemSelectText

        return {
          item: function(classNames, data) {
            return template('<div class="' + String(classNames.item) + ' ' + String(data.highlighted ? classNames.highlightedState : classNames.itemSelectable) + '" data-item data-id="' + String(data.id) + '" data-value="' + String(data.value) + '"' + String(data.active ? 'aria-selected="true"' : '') + '' + String(data.disabled ? 'aria-disabled="true"' : '') + '><span class="dropdown-item-indicator">' + data.customProperties + '</span>' + String(data.label) + '</div>')
          },
          choice: function(classNames, data) {
            return template('<div class="' + String(classNames.item) + ' ' + String(classNames.itemChoice) + ' ' + String(data.disabled ? classNames.itemDisabled : classNames.itemSelectable) + '" data-select-text="' + String(itemSelectText) + '" data-choice  ' + String(data.disabled ? 'data-choice-disabled aria-disabled="true"' : 'data-choice-selectable') + ' data-id="' + String(data.id) + '" data-value="' + String(data.value) + '" ' + String(data.groupId > 0 ? 'role="treeitem"' : 'role="option"') + ' ><span class="dropdown-item-indicator">' + data.customProperties + '</span>' + String(data.label) + '</div>')
          }
        }
      }
    })

    if (this.remoteSearchEnabledValue) {
      let remoteSearchUrl = this.remoteSearchUrlValue
      let lookupDelay = 300
      let lookupTimeout = null

      this.selectTarget.addEventListener('search', function(event) {
        clearTimeout(lookupTimeout)

        if (event.detail.value && event.detail.value.length >= 3) {
          lookupTimeout = setTimeout(() => {
            choices.clearChoices()
            choices.setChoices(async () => {
              const response = await fetch(
                remoteSearchUrl + event.detail.value
              )
              return await response.json()
            })
          }, lookupDelay)
        }
      })

      this.selectTarget.addEventListener('choice', function(event) {
        choices.clearChoices()
      })
    }
  }
}
