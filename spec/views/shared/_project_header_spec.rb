require 'rails_helper'

describe 'shared/_project_header.html.rb' do
  let!(:issuer) { create(:account) }

  before do
    assign :current_account, issuer
  end

  context "with _token_type eq 'erc20'" do
    let!(:project) do
      create(:project, ethereum_enabled: true, token: create(:token, contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', _token_type: 'erc20', _blockchain: :ethereum_ropsten))
    end

    before do
      assign :project, project.decorate
      render
    end

    specify do
      expect(rendered).to have_css 'div[data-react-class="layouts/ProjectSetupHeader"]'
    end
  end
end
