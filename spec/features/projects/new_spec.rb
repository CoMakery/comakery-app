require 'rails_helper'

RSpec.feature 'Project New', type: :feature, js: true do
  let(:account) { FactoryBot.create(:account) }

  let(:project) { Project.last }

  before { login(account) }

  scenario 'user creates a new project with valid form data' do
    visit new_project_path

    fill_in 'project[title]', with: Faker::Lorem.word

    fill_in 'project[description]', with: Faker::Lorem.sentence

    click_on 'create & close'

    expect(page).to have_content('Create a New Batch')

    expect(page).to have_current_path project_award_types_path(project)
  end

  scenario 'user fixes form validation errors and retries create' do
    visit new_project_path

    fill_in 'project[title]', with: Faker::Lorem.word

    fill_in 'project[description]', with: Faker::Lorem.sentence

    fill_in 'project[video_url]', with: Faker::Lorem.word

    click_on 'create & close'

    expect(page).to have_content('Video url must be a valid url')

    fill_in 'project[video_url]', with: ''

    click_on 'create & close'

    expect(page).to have_content('Create a New Batch')

    expect(page).to have_current_path project_award_types_path(project)
  end
end
