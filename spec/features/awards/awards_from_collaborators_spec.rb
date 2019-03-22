require 'rails_helper'

#   it 'allow creating of award types that are community-awardable' do
#     stub_slack_channel_list
#     stub_slack_user_list([slack_user(first_name: 'collab1', last_name: 'collab1', user_id: 'collab1'),
#                           slack_user(first_name: 'collab2', last_name: 'collab2', user_id: 'collab2'),
#                           slack_user(first_name: 'owner', last_name: 'owner', user_id: 'owner_id')])

#     login(owner)

#     visit my_project_path

#     click_link 'New Project'

#     award_type_inputs = get_award_type_rows
#     expect(award_type_inputs.size).to be > 4

#     award_type_inputs[0].find("input[name*='[name]']").set 'This will be a community awardable award'
#     award_type_inputs[0].find("input[name*='[amount]']").set '10'
#     award_type_inputs[0].find("input[name*='[community_awardable]'][type='checkbox']").set(true)

#     click_on 'Save', class: 'last_submit'

#     expect(page).to have_content 'Project created'

#     bookmark_project_path = page.current_path

#     login(collab1)

#     visit bookmark_project_path
#   end
# end
