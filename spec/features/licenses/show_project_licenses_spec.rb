require 'rails_helper'
require 'refile/file_double'
feature 'licenses' do
  let!(:account) { create :account }
  let!(:project) do
    create(:project,
      title: 'Cats with Lazers Project',
      description: 'cats with lazers',
      account: account,
      visibility: 'public_listed')
  end

  scenario '#index' do
    visit project_path(project)
    click_link 'Contribution License'
    expect(page).to have_content 'Project Terms'
  end
end
