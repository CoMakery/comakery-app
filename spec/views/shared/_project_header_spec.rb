require 'rails_helper'

describe 'shared/_project_header.html.rb' do
  let!(:issuer) { create(:account) }

  before do
    assign :current_account, issuer
  end

  context "with _token_type eq 'erc20'" do
    let!(:project) do
      stub_token_symbol
      create(:project, ethereum_enabled: true, token: create(:token, contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', _token_type: 'erc20'))
    end

    before do
      assign :project, project.decorate
      render
    end

    specify do
      expect(rendered).to have_css 'div[data-react-class="layouts/ProjectSetupHeader"]'
    end
  end

  context "with _token_type eq 'qrc20'" do
    let!(:project) do
      create(:project, token: create(:token, ethereum_enabled: true, contract_address: '583cbbb8a8443b38abcc0c956bece47340ea1367', _token_type: 'qrc20', _blockchain: 'qtum_test'))
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
