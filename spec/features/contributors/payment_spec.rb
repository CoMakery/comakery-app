require 'rails_helper'

describe 'contributors', type: :feature, js: true do
  let!(:team) { create :team }
  let!(:project) { create(:project, title: 'Project that needs awards', payment_type: 'revenue_share', account: account, ethereum_enabled: true, ethereum_contract_address: '0x' + '2' * 40) }
  let!(:small_award_type) { create(:award_type, project: project, name: 'Small') }
  let!(:account) { create(:account, email: 'hubert@example.com') }
  let!(:other_account) { create(:account, nickname: 'sherman', email: 'sherman@example.com') }

  let!(:owner_authentication) { create(:authentication, uid: 'hubert id', account: account) }
  let!(:sherman_authentication) { create(:authentication, uid: 'sherman id', account: other_account) }

  before do
    team.build_authentication_team owner_authentication
    team.build_authentication_team sherman_authentication
  end

  describe 'when awards and payments have been issued' do
    before do
      stub_slack_user_list([])
      create(:award, award_type: small_award_type, quantity: 1, amount: 10, issuer: account, account: other_account)
      project.revenues.create(amount: 100, currency: 'USD', recorded_by: account)
      project.payments.create_with_quantity(account: other_account,
                                            quantity_redeemed: 5)
    end

    it 'populates shows the earned, paid, remaining' do
      login(account)

      visit project_contributors_path(project)

      within(first('.award-row')) do
        expect(page.find('.award-holdings')).to have_content '5'
        expect(page.find('.awards-earned')).to have_content '10'
        expect(page.find('.paid')).to have_content '$2.95'
        expect(page.find('.holdings-value')).to have_content '$2.95'
        expect(page.find('.contributor')).to have_content 'sherman'
      end
    end
  end
end
