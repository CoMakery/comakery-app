require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'ethereum_explorer_domain' do
    context 'with nil ethereum network' do
      it 'returns detault ethereum explorer domain' do
        expect(helper.ethereum_explorer_domain(create(:token, ethereum_network: nil))).to eq(Rails.application.config.ethereum_explorer_site)
      end
    end

    context 'with main ethereum network' do
      it 'returns etherscan.io' do
        expect(helper.ethereum_explorer_domain(create(:token, ethereum_network: 'main'))).to eq('etherscan.io')
      end
    end

    context 'with others ethereum networks' do
      it 'returns etherscan.io subdomain with that network' do
        expect(helper.ethereum_explorer_domain(create(:token, ethereum_network: 'ropsten'))).to eq('ropsten.etherscan.io')
      end
    end
  end

  describe 'ethereum_explorer_tx_url' do
    it 'returns exporer url for a transaction' do
      expect(helper.ethereum_explorer_tx_url(create(:token, ethereum_network: 'ropsten'), '123')).to eq('https://ropsten.etherscan.io/tx/123')
    end
  end

  describe 'ransack_filter_present?' do
    let!(:q) { Award.all.ransack(transfer_type_id_eq: '1202') }

    context 'when there is a condition with matching predicate, attribute and value' do
      it 'returns true' do
        expect(ransack_filter_present?(q, 'transfer_type_id', 'eq', '1202')).to be_truthy
      end
    end

    context 'when there is a condition with matching predicate, attribute, but not value' do
      it 'returns false' do
        expect(ransack_filter_present?(q, 'transfer_type_id', 'eq', '1201')).to be_falsey
      end
    end

    context 'when there is a condition with matching predicate, value, but not attribute' do
      it 'returns false' do
        expect(ransack_filter_present?(q, 'transfer_type_ids', 'eq', '1202')).to be_falsey
      end
    end

    context 'when there is a condition with matching attribute, value, but not predicate' do
      it 'returns false' do
        expect(ransack_filter_present?(q, 'transfer_type_id', 'gt', '1202')).to be_falsey
      end
    end
  end
end
