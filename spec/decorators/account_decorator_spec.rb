require 'rails_helper'

describe AccountDecorator do
  subject(:account) { create :account, password: '12345678' }

  before do
    stub_discord_channels
  end

  describe '#name' do
    it 'returns the first and last name and falls back to the user name' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson').decorate.name).to eq('Bob Johnson')
      expect(build(:account, first_name: nil, last_name: 'Johnson').decorate.name).to eq('Johnson')
      expect(build(:account, first_name: 'Bob', last_name: '').decorate.name).to eq('Bob')
    end
  end

  describe '#nick' do
    it 'returns the nickname and falls back to the name' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson', nickname: nil).decorate.nick).to eq('Bob Johnson')
      expect(build(:account, first_name: nil, last_name: 'Johnson', nickname: nil).decorate.nick).to eq('Johnson')
      expect(build(:account, first_name: 'Bob', last_name: '', nickname: nil).decorate.nick).to eq('Bob')
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson', nickname: 'bobjon').decorate.nick).to eq('bobjon')
    end
  end

  describe '#name_with_nickname' do
    it 'combines name and nickname' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson', nickname: 'bobjon').decorate.name_with_nickname).to eq('Bob Johnson (bobjon)')
    end

    it 'returns only name if nickname is not present' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson', nickname: nil).decorate.name_with_nickname).to eq('Bob Johnson')
    end
  end

  describe '#can_send_awards?' do
    let!(:project_owner) { create(:account, ethereum_wallet: '0x3551cd3a70e07b3484f20d9480e677243870d67e') }

    context 'on ethereum network' do
      let!(:project) { create :project, payment_type: 'project_token' }
      let!(:project2) { build :project, payment_type: 'project_token', account: project_owner, token: build(:token, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005') }

      it 'can send' do
        expect(project_owner.decorate.can_send_awards?(project2)).to be true
      end

      it 'cannot send' do
        expect(project_owner.decorate.can_send_awards?(project)).to be false
      end
    end

    context 'on bitcoin network' do
      let!(:recipient) { create(:account, bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps') }
      let!(:project) { build :project, payment_type: 'project_token', account: project_owner, token: create(:token, coin_type: 'btc') }

      it 'can send' do
        expect(project_owner.decorate.can_send_awards?(project)).to be true
      end

      it 'cannot send' do
        project.token.coin_type = nil
        expect(project_owner.decorate.can_send_awards?(project)).to be false
      end
    end
  end

  describe '#can_receive_awards?' do
    context 'on ethereum network' do
      let!(:recipient) { create(:account, ethereum_wallet: '0x3551cd3a70e07b3484f20d9480e677243870d67e') }
      let!(:project) { build :project, payment_type: 'project_token', token: create(:token, coin_type: 'eth') }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.ethereum_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'on bitcoin network' do
      let!(:recipient) { create(:account, bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps') }
      let!(:project) { build :project, payment_type: 'project_token', token: create(:token, coin_type: 'btc') }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.bitcoin_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'on cardano network' do
      let!(:recipient) { create(:account, cardano_wallet: 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp') }
      let!(:project) { build :project, payment_type: 'project_token', token: create(:token, coin_type: 'ada') }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.cardano_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'on qtum network' do
      let!(:recipient) { create(:account, qtum_wallet: 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM') }
      let!(:project) { build :project, payment_type: 'project_token', token: create(:token, coin_type: 'qrc20') }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.qtum_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'coin_type nil' do
      let!(:recipient) { create(:account, qtum_wallet: 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM') }
      let!(:project) { build :project, payment_type: 'project_token', token: create(:token, coin_type: nil) }

      it 'returns false' do
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end
  end

  describe 'image_url' do
    let!(:account_w_image) { create(:account, image: Refile::FileDouble.new('dummy', 'dummy_image.png', content_type: 'image/png')) }
    let!(:account_wo_image) { create :account }

    it 'returns image_url if present' do
      expect(account_w_image.decorate.image_url).to include('dummy_image')
    end

    it 'returns default image' do
      expect(account_wo_image.decorate.image_url).to include('default_account_image')
    end
  end

  describe 'wallet_address_link_for' do
    let!(:account_w_wallet) { create(:account, ethereum_wallet: '0x3551cd3a70e07b3484f20d9480e677243870d67e', bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps') }
    let!(:account_wo_wallet) { create(:account, ethereum_wallet: nil) }
    let!(:project_w_token) { create :project, token: create(:token, coin_type: 'eth', ethereum_network: :main) }
    let!(:project_wo_token) { create :project, token: nil }
    let!(:project_w_token_on_ropsten) { create :project, token: create(:token, coin_type: :comakery, ethereum_network: :ropsten) }
    let!(:project_w_token_on_bitcoin_testnet) { create :project, token: create(:token, coin_type: :btc, blockchain_network: :bitcoin_testnet) }

    it 'returns link for wallet address if account has address for project token' do
      expect(account_w_wallet.decorate.wallet_address_link_for(project_w_token)).to include(account_w_wallet.ethereum_wallet)
    end

    it 'returns placeholder if account doesnt have address for project token' do
      expect(account_w_wallet.decorate.wallet_address_link_for(project_wo_token)).to eq('needs wallet')
      expect(account_wo_wallet.decorate.wallet_address_link_for(project_wo_token)).to eq('needs wallet')
      expect(account_wo_wallet.decorate.wallet_address_link_for(project_w_token)).to eq('needs wallet')
    end

    it 'returns link with correct network' do
      expect(account_w_wallet.decorate.wallet_address_link_for(project_w_token_on_ropsten)).to include('ropsten')
      expect(account_w_wallet.decorate.wallet_address_link_for(project_w_token_on_bitcoin_testnet)).to include('btc-testnet')
    end
  end

  describe 'verification_state' do
    let!(:passed_account) { create(:account) }
    let!(:failed_account) { create(:account) }
    let!(:unknown_account) { create(:account) }

    it 'returns passed for passed_account' do
      create(:verification, account: passed_account, passed: true)
      expect(passed_account.reload.decorate.verification_state).to eq('passed')
    end

    it 'returns failed for failed_account' do
      create(:verification, account: failed_account, passed: false)
      expect(failed_account.reload.decorate.verification_state).to eq('failed')
    end

    it 'returns unknown for unknown_account' do
      expect(unknown_account.reload.decorate.verification_state).to eq('unknown')
    end
  end

  describe 'verification_date' do
    let!(:passed_account) { create(:account) }
    let!(:unknown_account) { create(:account) }

    it 'returns date for passed_account' do
      create(:verification, account: passed_account, passed: true)
      expect(passed_account.reload.decorate.verification_date).not_to be_nil
    end

    it 'returns nil for unknown_account' do
      expect(unknown_account.reload.decorate.verification_date).to be_nil
    end
  end

  describe 'verification_max_investment_usd' do
    let!(:passed_account) { create(:account) }
    let!(:unknown_account) { create(:account) }

    it 'returns max_investment_usd for passed_account' do
      max_investment_usd = 100

      create(:verification, account: passed_account, passed: true, max_investment_usd: max_investment_usd)
      expect(passed_account.reload.decorate.verification_max_investment_usd).to eq(max_investment_usd)
    end

    it 'returns nil for unknown_account' do
      expect(unknown_account.reload.decorate.verification_max_investment_usd).to be_nil
    end
  end

  describe 'total_received_in' do
    let!(:account) { create(:account) }
    let!(:token) { create(:token) }
    let!(:token2) { create(:token) }
    let!(:award_type) { create(:award_type, project: create(:project, token: token)) }
    let!(:award_type2) { create(:award_type, project: create(:project, token: token2)) }

    before do
      create(:award, account: account, status: :paid, amount: 1, award_type: award_type)
      create(:award, account: account, status: :paid, amount: 2, award_type: award_type)
      create(:award, account: account, status: :rejected, amount: 4, award_type: award_type)
      create(:award, account: account, status: :paid, amount: 8, award_type: award_type2)
    end

    it 'sums up total_amounts of account paid tasks from projects using given token' do
      expect(account.decorate.total_received_in(token)).to eq(3)
    end
  end
end
