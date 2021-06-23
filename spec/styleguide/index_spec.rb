require 'rails_helper'

describe 'tokens features', type: :feature do
  scenario 'index' do
    visit '/dev/styleguide/index.html'
    within('h2') { expect(page.text).to eq('Dashboard') }
  end
end
