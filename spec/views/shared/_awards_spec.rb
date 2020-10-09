require 'rails_helper'

describe 'shared/_awards.html.rb' do
  let!(:team) { create :team }
  let!(:issuer) { create(:account) }
  let!(:recipient1) { create(:account) }
  let!(:recipient2) { create(:account) }
  let!(:issuer_auth) { create(:authentication, account: issuer) }
  let!(:recipient1_auth) { create(:authentication, account: recipient1) }
  let!(:recipient2_auth) { create(:authentication, account: recipient2) }
  let!(:project) do
    stub_token_symbol
    create(:project, account: issuer, token: create(:token, ethereum_enabled: true, contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', _token_type: 'erc20', _blockchain: :ethereum_ropsten))
  end
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award1) { create(:award, award_type: award_type, description: 'markdown _rocks_: www.auto.link', issuer: issuer, account: recipient1).decorate }
  let!(:award2) { create(:award, award_type: award_type, description: 'awesome', issuer: issuer, account: recipient2).decorate }

  before do
    team.build_authentication_team issuer_auth
    team.build_authentication_team recipient1_auth
    team.build_authentication_team recipient2_auth
  end

  before { assign :project, project.decorate }
  before { assign :awards, [award1] }
  before { assign :show_recipient, true }
  before { assign :current_account, issuer }

  describe 'Description column' do
    it 'renders mardown as HTML' do
      render
      assert_select '.description', html: %r{markdown <em>rocks</em>:}
      assert_select '.description', html: %r{<a href="http://www.auto.link"[^>]*>www.auto.link</a>}
    end
  end

  describe 'awards history' do
    before do
      award1.update(quantity: 2, unit_amount: 5, total_amount: 10)
      render
    end

    specify do
      expect(rendered).to have_css '.award-unit-amount', text: '5'
    end

    specify do
      expect(rendered).to have_css '.award-quantity', text: '2'
    end

    specify do
      expect(rendered).to have_css '.award-total-amount', text: '10'
    end
  end
end
