require 'rails_helper'

describe 'Create Transfer Type' do
  let(:owner) { create :account }
  let(:project) { create :project, account: owner }

  example 'Returns correct number of transfers after applying filter' do
    login(owner)
    visit project_dashboard_transfer_categories_path(project)

    find('.project_settings').click_on 'create transfer category ＋'

    within('form.reg-groups__form:not(.hidden)') do
      fill_in 'Name', with: 'New Category'

      click_button 'create'
    end

    expect(find('.flash-message-container')).to have_content 'Transfer Category created'
    expect(find('.reg-groups')).to have_content 'New Category'
  end
end
