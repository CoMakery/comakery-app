require 'rails_helper'

describe 'Collaborator projects' do
  let!(:owner) { create(:account, email: 'gleenn@example.com').tap { |a| create(:authentication, account: a) } }
  let!(:collab1) { create(:account, email: 'collab1@example.com').tap { |a| create(:authentication, account: a) } }
  let!(:collab2) { create(:account, email: 'collab2@example.com').tap { |a| create(:authentication, account: a) } }

  it 'allow creating of award types that are community-awardable' do
    stub_slack_channel_list
    stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
                          slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2'),
                          slack_user(first_name: 'owner', last_name: 'owner', user_id: 'owner_id')])

    login(owner)

    visit root_path

    click_link 'New Project'

    fill_in 'Title', with: 'Super title'
    fill_in 'Description', with: 'This is a project description which is very informative'
    attach_file 'Project Image', Rails.root.join('spec', 'fixtures', 'helmet_cat.png')
    fill_in 'project_maximum_tokens', with: '210000'
    fill_in "Project Owner's Legal Name", with: 'Mindful Inc'
    fill_in 'project_royalty_percentage', with: 10.75
    check 'Contributions are exclusive'
    check 'Require project and business confidentiality'

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to be > 4

    award_type_inputs[0].find("input[name*='[name]']").set 'This will be a community awardable award'
    award_type_inputs[0].find("input[name*='[amount]']").set '10'
    award_type_inputs[0].find("input[name*='[community_awardable]'][type='checkbox']").set(true)

    click_on 'Save'

    expect(page).to have_content 'Project created'

    bookmark_project_path = page.current_path

    login(collab1)

    visit bookmark_project_path
  end
end
