require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  context 'when not owner' do
    let!(:team) {create :team}
    let!(:owner) { create(:account) }
    let!(:owner_auth) { create(:authentication, account: owner) }
    let!(:other_account) { create(:account) }
    let!(:other_account_auth) { create(:authentication, account: other_account) }
    let!(:project) { create(:project, public: true, account: owner) }
    let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1000) }
    let!(:community_award_type) { create(:award_type, project: project, community_awardable: true, amount: 10) }
    let!(:award) { create(:award, award_type: award_type, account: other_account) }
    let!(:community_award) { create(:award, award_type: community_award_type, account: owner) }

    before do
      team.build_authentication_team owner_auth
      team.build_authentication_team other_account_auth
      stub_slack_user_list
      stub_slack_channel_list
    end

    context 'when logged in as non-owner' do
      context 'viewing projects' do
        before { login(other_account) }

        it 'shows radio buttons for community awardable awards' do
          visit project_path(project)

          within('.award-types') do
            expect(page.all('input[type=radio]').size).to eq(2)
            expect(page.all('input[type=radio][disabled=disabled]').size).to eq(1)
            expect(page).to have_content 'User'
            expect(page).to have_content 'Description'
          end
        end
      end
    end

    context 'when logged out' do
      context 'viewing projects' do
        it "doesn't show forms for awarding" do
          visit project_path(project)

          within('.award-types') do
            expect(page.all('input[type=radio]').size).to eq(0)
            expect(page.all('input[type=radio][disabled=disabled]').size).to eq(0)
            expect(page).not_to have_content 'User'
            expect(page).not_to have_content 'Description'
          end
        end
      end

      context 'viewing awards' do
        it 'lets people view awards' do
          visit project_path(project)

          click_link 'Awards'
          expect(page).to have_content 'Project Tokens Awarded'
        end

        it 'paginates when there are lots of awards' do
          (305 - project.awards.count).times do
            create(:award, award_type: community_award_type, issuer: other_account, authentication: owner_auth)
          end

          visit project_path(project)

          click_link 'Awards'
          expect(page.all('table.award-rows tr.award-row').size).to eq(50)
          expect(page).to have_content '1 2 3 4 5 … Next › Last »'

          within(page.all('.pagination').first) do
            click_link 'Last'
          end
          expect(page.all('table.award-rows tr.award-row').size).to eq(5)
          expect(page).to have_content '« First ‹ Prev … 3 4 5 6 7'
        end
      end
    end
  end
end
