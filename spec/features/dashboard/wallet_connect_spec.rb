require 'rails_helper'

shared_examples 'having wallet connect button' do |attrs|
  let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let!(:project) { transfer.project }

  before do
    project.update!(visibility: :public_listed)
  end

  subject { visit send(attrs[:path_helper], project) }

  context 'without a token', unless: attrs[:requires_token] do
    before do
      transfer.ready!
      project.update!(token: nil)
      subject
    end

    it 'is not present' do
      expect(page).not_to have_css('.wallet-connect--button')
    end
  end

  it 'loads stimulus controllers' do
    expect(page).to have_css('div[data-controller="sign--wallet-connect sign--metamask sign--ore-id"]', count: 1)
  end

  context 'with a token supported by OREID' do
    context 'and logged in as project admin' do
      before do
        transfer.ready!
        login(project.account)
        subject
      end

      it 'links to OREID stimulus controller' do
        expect(page).to have_css('.wallet-connect--button', count: 1, text: 'ORE ID')
        expect(page).to have_css('.wallet-connect--button[data-action="click->sign--ore-id#switch"]', count: 1)
        expect(page).to have_css('.wallet-connect--button[data-sign--ore-id-target="connectButton"]', count: 1)
        expect(page).to have_css('.wallet-connect--button .wallet-logo')
      end

      it 'has address element' do
        expect(page).to have_css('.wallet-connect--address', count: 1, text: 'Disconnected')
        expect(page).to have_css('.wallet-connect--address[data-sign--wallet-connect-target="walletAddress"]', count: 1)
        expect(page).to have_css('.wallet-connect--address[data-sign--metamask-target="walletAddress"]', count: 1)
      end
    end
  end

  context 'with a token supported by WalletConnect, Metamask and OREID' do
    let!(:transfer) { build(:blockchain_transaction).blockchain_transactable }
    let!(:project) { transfer.project }

    context 'and not logged in' do
      before do
        subject
      end

      it 'is not present' do
        expect(page).not_to have_css('.wallet-connect--button')
      end
    end

    context 'and not logged as a project admin' do
      before do
        login(transfer.account)
        subject
      end

      it 'is not present' do
        expect(page).not_to have_css('.wallet-connect--button')
      end
    end

    context 'and logged in as project admin' do
      before do
        login(project.account)
        subject
      end

      it 'links to WalletConnect stimulus controller' do
        expect(page).to have_css('.wallet-connect--button', count: 1, text: 'WalletConnect')
        expect(page).to have_css('.wallet-connect--button[data-action="click->sign--wallet-connect#switch"]', count: 1)
        expect(page).to have_css('.wallet-connect--button[data-sign--wallet-connect-target="otherConnectButtons"]', count: 2)
        expect(page).to have_css('.wallet-connect--button[data-sign--wallet-connect-target="connectButton"]', count: 1)
        expect(page).to have_css('.wallet-connect--button .wallet-logo')
      end

      it 'links to MetaMask stimulus controller' do
        expect(page).to have_css('.wallet-connect--button', count: 1, text: 'MetaMask')
        expect(page).to have_css('.wallet-connect--button[data-action="click->sign--metamask#switch"]', count: 1)
        expect(page).to have_css('.wallet-connect--button[data-sign--metamask-target="otherConnectButtons"]', count: 2)
        expect(page).to have_css('.wallet-connect--button[data-sign--metamask-target="connectButton"]', count: 1)
        expect(page).to have_css('.wallet-connect--button .wallet-logo')
      end

      it 'links to OREID stimulus controller' do
        expect(page).to have_css('.wallet-connect--button', count: 1, text: 'ORE ID')
        expect(page).to have_css('.wallet-connect--button[data-action="click->sign--ore-id#switch"]', count: 1)
        expect(page).to have_css('.wallet-connect--button[data-sign--ore-id-target="otherConnectButtons"]', count: 2)
        expect(page).to have_css('.wallet-connect--button[data-sign--ore-id-target="connectButton"]', count: 1)
        expect(page).to have_css('.wallet-connect--button .wallet-logo')
      end

      it 'has address element' do
        expect(page).to have_css('.wallet-connect--address', count: 1, text: 'Disconnected')
        expect(page).to have_css('.wallet-connect--address[data-sign--wallet-connect-target="walletAddress"]', count: 1)
        expect(page).to have_css('.wallet-connect--address[data-sign--metamask-target="walletAddress"]', count: 1)
      end
    end
  end
end
