require 'rails_helper'

describe 'contributors' do
  let!(:project) { create(:project, title: 'Project that needs awards', owner_account: owner_account, slack_team_id: 'team id', ethereum_enabled: true, ethereum_contract_address: '0x' + '2' * 40) }
  let!(:small_award_type) { create(:award_type, project: project, name: 'Small', amount: 10) }
  let!(:owner_account) { create(:account, email: 'hubert@example.com') }
  let!(:other_account) { create(:account, email: 'sherman@example.com') }

  let!(:owner_authentication) { create(:authentication, slack_user_name: 'hubert', slack_first_name: 'Hubert', slack_last_name: 'Sherbert', slack_user_id: 'hubert id', account: owner_account, slack_team_id: 'team id', slack_team_image_34_url: 'http://avatar.com/owner_team_avatar.jpg') }
  let!(:sherman_authentication) { create(:authentication, slack_user_name: 'sherman', slack_user_id: 'sherman id', slack_first_name: 'Sherman', slack_last_name: 'Yessir', account: other_account, slack_team_id: 'team id', slack_image_32_url: 'http://avatar.com/other_account_avatar.jpg') }

  describe 'when awards and payments have been issued' do
    before do
      stub_slack_user_list([])
      small_award_type.awards.create_with_quantity(1, issuer: owner_account, authentication: sherman_authentication)
      project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner_account)
      project.payments.create_with_quantity(payee_auth: sherman_authentication,
                                            quantity_redeemed: 5)
    end

    it 'populates shows the earned, paid, remaining' do
      login(owner_account)

      visit project_contributors_path(project)
      within(first('.award-row')) do
        expect(page.find('.award-holdings')).to have_content '5'
        expect(page.find('.awards-earned')).to have_content '10'
        expect(page.find('.paid')).to have_content '$2.95'
        expect(page.find('.holdings-value')).to have_content '$2.95'
        expect(page.find('.contributor')).to have_content 'Sherman Yessir'
      end
    end
  end
end
