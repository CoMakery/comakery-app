require 'rails_helper'

describe 'shared/_project_header.html.rb' do
  let!(:issuer) { create(:account) }

  before do
    assign :current_account, issuer
  end

  context "with coin_type eq 'erc20'" do
    let!(:project) do
      stub_token_symbol
      create(:project, ethereum_enabled: true, ethereum_contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', coin_type: 'erc20')
    end

    before do
      assign :project, project.decorate
      render
    end

    specify do
      expect(rendered).to have_link 'Ξthereum Token'
    end
  end

  context "with coin_type eq 'qrc20'" do
    let!(:project) do
      create(:project, ethereum_enabled: true, contract_address: '583cbbb8a8443b38abcc0c956bece47340ea1367', coin_type: 'qrc20', blockchain_network: 'qtum_testnet')
    end

    before do
      assign :project, project.decorate
      render
    end

    specify do
      expect(rendered).to have_link 'Qtum Token'
    end
  end
end
