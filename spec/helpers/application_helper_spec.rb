require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
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

  context '#deploy_to_heroku_url' do
    let(:project) { create(:project, token: token, id: 123) }
    subject { deploy_to_heroku_url(project) }

    before do
      allow(request).to receive(:protocol).and_return('https://')
      allow(request).to receive(:host_with_port).and_return('comakery.com')
      stub_const('ENV', ENV.to_hash.merge('PURESTAKE_API' => 'purestake_api_key'))
      stub_const('ENV', ENV.to_hash.merge('INFURA_HOT_WALLET_KEY' => 'infura_api_key'))
    end

    context 'for eth blockchain without batch contract' do
      let(:token) { build(:erc20_token, contract_address: build(:ethereum_contract_address), symbol: 'XYZ') }
      it 'contain INFURA_PROJECT_ID, ETHEREUM_CONTRACT_ADDRESS and ETHEREUM_TOKEN_SYMBOL' do
        is_expected.to eq 'https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet&env%5BBLOCKCHAIN_NETWORK%5D=ethereum_ropsten&env%5BCOMAKERY_SERVER_URL%5D=https%3A%2F%2Fcomakery.com&env%5BETHEREUM_CONTRACT_ADDRESS%5D=0x1D1592c28FFF3d3E71b1d29E31147846026A0a37&env%5BETHEREUM_TOKEN_SYMBOL%5D=XYZ&env%5BETHEREUM_TOKEN_TYPE%5D=erc20&env%5BINFURA_PROJECT_ID%5D=infura_api_key&env%5BPROJECT_ID%5D=123'
      end
    end

    context 'for eth blockchain with batch contract' do
      let(:token) { build(:erc20_token, contract_address: build(:ethereum_contract_address), symbol: 'XYZ', batch_contract_address: '0x68ac9A329c688AfBf1FC2e5d3e8Cb6E88989E2cC') }
      it 'contain INFURA_PROJECT_ID, ETHEREUM_CONTRACT_ADDRESS, ETHEREUM_APPROVAL_CONTRACT_ADDRESS and ETHEREUM_TOKEN_SYMBOL' do
        is_expected.to eq 'https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet&env%5BBLOCKCHAIN_NETWORK%5D=ethereum_ropsten&env%5BCOMAKERY_SERVER_URL%5D=https%3A%2F%2Fcomakery.com&env%5BETHEREUM_APPROVAL_CONTRACT_ADDRESS%5D=0x68ac9A329c688AfBf1FC2e5d3e8Cb6E88989E2cC&env%5BETHEREUM_CONTRACT_ADDRESS%5D=0x1D1592c28FFF3d3E71b1d29E31147846026A0a37&env%5BETHEREUM_TOKEN_SYMBOL%5D=XYZ&env%5BETHEREUM_TOKEN_TYPE%5D=erc20_batch&env%5BINFURA_PROJECT_ID%5D=infura_api_key&env%5BPROJECT_ID%5D=123'
      end
    end

    context 'for eth lockup contract' do
      let(:token) { build(:lockup_token, contract_address: '0x9608848FA0063063d2Bb401e8B5efFcb8152Ec65', symbol: 'XYZ', batch_contract_address: nil) }
      it 'contain INFURA_PROJECT_ID, ETHEREUM_CONTRACT_ADDRESS, ETHEREUM_APPROVAL_CONTRACT_ADDRESS and ETHEREUM_TOKEN_SYMBOL' do
        is_expected.to eq 'https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet&env%5BBLOCKCHAIN_NETWORK%5D=ethereum_rinkeby&env%5BCOMAKERY_SERVER_URL%5D=https%3A%2F%2Fcomakery.com&env%5BETHEREUM_APPROVAL_CONTRACT_ADDRESS%5D=&env%5BETHEREUM_CONTRACT_ADDRESS%5D=0x9608848FA0063063d2Bb401e8B5efFcb8152Ec65&env%5BETHEREUM_TOKEN_SYMBOL%5D=XYZ&env%5BETHEREUM_TOKEN_TYPE%5D=token_release_schedule&env%5BINFURA_PROJECT_ID%5D=infura_api_key&env%5BPROJECT_ID%5D=123'
      end
    end

    context 'for algorand blockchain' do
      let(:token) { build(:algorand_token, contract_address: 'algorand_contract_address') }

      it 'contains PURESTAKE_API and OPT_IN_APP params' do
        is_expected.to eq 'https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet&env%5BBLOCKCHAIN_NETWORK%5D=algorand_test&env%5BCOMAKERY_SERVER_URL%5D=https%3A%2F%2Fcomakery.com&env%5BOPT_IN_APP%5D=algorand_contract_address&env%5BPROJECT_ID%5D=123&env%5BPURESTAKE_API%5D=purestake_api_key'
      end
    end
  end
end
