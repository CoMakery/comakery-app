require 'rails_helper'

feature 'project searching', :js do
  let!(:project_not_matching) { create(:project, visibility: 'public_listed') }
  let!(:project_w_matching_title) { create(:project, title: 'Find me', visibility: 'public_listed') }
  let!(:project_w_matching_description) { create(:project, description: 'Find me', visibility: 'public_listed') }
  let!(:project_w_matching_token) { create(:project, token: create(:token, name: 'Find me'), visibility: 'public_listed') }
  let!(:project_w_matching_mission) { create(:project, mission: create(:mission, name: 'Find me'), visibility: 'public_listed') }

  it 'allows searching for projects using title, description, token name or mission name' do
    visit root_path

    fill_in 'q_title_or_description_or_token_name_or_mission_name_cont', with: "find me\n"

    expect(page).to have_content('Project Search: find me')

    expect(page).to have_link(href: "/projects/#{project_w_matching_title.id}")
    expect(page).to have_link(href: "/projects/#{project_w_matching_description.id}")
    expect(page).to have_link(href: "/projects/#{project_w_matching_token.id}")
    expect(page).to have_link(href: "/projects/#{project_w_matching_mission.id}")
    expect(page).not_to have_link(href: "/projects/#{project_not_matching.id}")
  end
end
