import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  visitSelectedCategory() {
    let selected = $('#category-selector').find('option:selected')
    if (selected.val() !== 'All') {
      Turbo.visit(selected.data('url'))
    }
  }
}
