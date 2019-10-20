require 'rails_helper'

describe Token do
  describe 'scopes' do
    describe '.listed' do
      let!(:token) { create(:token) }
      let!(:token_unlisted)  { create(:token, unlisted: true) }

      it 'returns all tokens expect unlisted ones' do
        expect(described_class.listed).to include(token)
        expect(described_class.listed).not_to include(token_unlisted)
      end
    end
  end

  describe 'validations' do
    it 'raises error if not found Ethereum address' do
      stub_const('Comakery::Ethereum::ADDRESS', {})
      expect(Comakery::Ethereum::ADDRESS['account']).to be_nil
      stub_token_symbol
      expect { described_class.create(ethereum_contract_address: '111') }.to raise_error(ArgumentError)
    end

    describe 'denomination enumeration' do
      let(:token) { build :token }

      it 'default' do
        expect(described_class.new.denomination).to eq('USD')
      end

      specify do
        token.USD!
        expect(token.denomination).to eq('USD')
      end

      specify do
        token.BTC!
        expect(token.denomination).to eq('BTC')
      end

      specify do
        token.ETH!
        expect(token.denomination).to eq('ETH')
      end
    end

    describe 'denomination' do
      let(:token) { create :token, denomination: 'ETH' }

      it 'can be changed' do
        token.denomination = 'BTC'

        expect(token).to be_valid
      end

      # TODO: Uncomment when according migrations are finished (TASKS, BATCHES)
      # it 'cannot be changed after having associated with task' do
      #   create :task, token: token
      #   token.reload
      #   token.denomination = 'ETH'
      #
      #   expect(token).to be_invalid
      #   expect(token.errors[:denomination]).to eq(['cannot be changed if has associated tasks'])
      # end
    end

    describe 'coin_type' do
      let(:attrs) { { symbol: 'CBB', decimal_places: 8, ethereum_network: 'ropsten', ethereum_contract_address: '0x' + 'a' * 40, contract_address: 'a' * 40, blockchain_network: 'qtum_testnet' } }

      it 'eq erc20' do
        token = create :token, attrs.merge(coin_type: 'erc20')
        expect(token).to be_valid
        expect(token.reload.coin_type).to eq 'erc20'
        expect(token.blockchain_network).to be_nil
        expect(token.contract_address).to be_nil
        expect(token.ethereum_network).to eq 'ropsten'
        expect(token.ethereum_contract_address).to eq '0x' + 'a' * 40
        expect(token.symbol).to eq 'CBB'
        expect(token.decimal_places).to eq 8
      end

      it 'eq eth' do
        token = create :token, attrs.merge(coin_type: 'eth')
        expect(token).to be_valid
        expect(token.reload.coin_type).to eq 'eth'
        expect(token.blockchain_network).to be_nil
        expect(token.contract_address).to be_nil
        expect(token.ethereum_network).to eq 'ropsten'
        expect(token.ethereum_contract_address).to be_nil
        expect(token.symbol).to eq 'ETH'
        expect(token.decimal_places).to eq 18
      end

      it 'eq qrc20' do
        token = create :token, attrs.merge(coin_type: 'qrc20')
        expect(token).to be_valid
        expect(token.reload.coin_type).to eq 'qrc20'
        expect(token.blockchain_network).to eq 'qtum_testnet'
        expect(token.contract_address).to eq 'a' * 40
        expect(token.ethereum_network).to be_nil
        expect(token.ethereum_contract_address).to be_nil
        expect(token.symbol).to eq 'CBB'
        expect(token.decimal_places).to eq 8
      end
    end

    describe 'ethereum_enabled' do
      let(:token) { create(:token) }

      it { expect(token.ethereum_enabled).to eq(false) }

      it 'can be set to true' do
        token.ethereum_enabled = true
        token.save!
        token.reload
        expect(token.ethereum_enabled).to eq(true)
      end

      it 'if set to false can be set to false' do
        token.ethereum_enabled = false
        token.save!
        token.ethereum_enabled = false
        expect(token).to be_valid
      end

      it 'once set to true it cannot be set to false' do
        token.ethereum_enabled = true
        token.save!
        token.ethereum_enabled = false
        expect(token.tap(&:valid?).errors.full_messages.first)
          .to eq('Ethereum enabled cannot be set to false after it has been set to true')
      end
    end

    describe '#contract_address' do
      let(:token) { create(:token, coin_type: 'qrc20') }
      let(:address) { 'b' * 40 }

      it 'valid qtum contract address' do
        expect(build(:token, coin_type: 'qrc20', contract_address: nil)).to be_valid
        expect(token.tap { |o| o.contract_address = ('a' * 40).to_s }).to be_valid
        expect(token.tap { |o| o.contract_address = ('A' * 40).to_s }).to be_valid
      end

      it 'invalid qtum contract address' do
        expected_error_message = "Contract address should have 40 characters, should not start with '0x'"
        expect(token.tap { |o| o.contract_address = 'foo' }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(token.tap { |o| o.contract_address = '0x' }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(token.tap { |o| o.contract_address = "0x#{'a' * 38}" }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(token.tap { |o| o.contract_address = ('a' * 39).to_s }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(token.tap { |o| o.contract_address = ('f' * 41).to_s }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end

      it { expect(token.contract_address).to eq(nil) }

      it 'can be set' do
        token.contract_address = address
        token.save!
        token.reload
        expect(token.contract_address).to eq(address)
      end

      # TODO: Uncomment when according migrations are finished (TASKS, BATCHES)
      # it 'once has tasks associated cannot be set to another value' do
      #   create :task, token: token

      # token.contract_address = address
      # token.save!
      # token.reload
      # token.contract_address = 'c' * 40
      # expect(token).not_to be_valid
      # expect(token.errors.full_messages.to_sentence).to match \
      #   /cannot be changed if has associated tasks/
      # end
    end

    describe '#ethereum_contract_address' do
      let(:token) { create(:token) }
      let(:address) { '0x' + 'a' * 40 }

      it 'validates with a valid ethereum address' do
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: nil)).to be_valid
        expect(build(:token, ethereum_contract_address: "0x#{'a' * 40}")).to be_valid
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: "0x#{'A' * 40}")).to be_valid
      end

      it 'does not validate with an invalid ethereum address' do
        expected_error_message = "Ethereum contract address should start with '0x', followed by a 40 character ethereum address"
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: 'foo').tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: '0x').tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: "0x#{'a' * 39}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: "0x#{'a' * 41}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        stub_token_symbol
        expect(build(:token, ethereum_contract_address: "0x#{'g' * 40}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end

      it { expect(token.ethereum_contract_address).to eq(nil) }

      it 'can be set' do
        stub_token_symbol
        token.ethereum_contract_address = address
        token.save!
        token.reload
        expect(token.ethereum_contract_address).to eq(address)
      end

      # TODO: Uncomment when according migrations are finished (TASKS, BATCHES)
      # it 'once has tasks associated cannot be set to another value' do
      #   create :task, token: token

      # stub_token_symbol
      # token.ethereum_contract_address = address
      # token.save!
      # token.reload
      # token.ethereum_contract_address = 'c' * 40
      # stub_token_symbol
      # expect(token).not_to be_valid
      # expect(token.errors.full_messages.to_sentence).to match \
      #   /cannot be changed if has associated tasks/
      # end
    end
  end

  describe 'associations' do
    let!(:token) { create(:token, coin_type: :comakery) }
    let!(:project) { create(:project, token: token) }
    let!(:account_token_record) { create(:account_token_record, token: token) }
    let!(:reg_group) { create(:reg_group, token: token) }
    let!(:transfer_rule) { create(:transfer_rule, token: token) }

    it 'has many projects' do
      expect(token.projects).to match_array([project])
    end

    it 'has many account_token_records' do
      expect(token.account_token_records).to match_array([account_token_record])
    end

    it 'has many reg_groups' do
      expect(token.reg_groups).to match_array([reg_group])
    end

    it 'has many transfer_rules' do
      expect(token.transfer_rules).to match_array([transfer_rule])
    end
  end

  it 'enum of denominations should contain the platform wide currencies' do
    expect(described_class.denominations.map { |x, _| x }.sort).to eq(Comakery::Currency::DENOMINATIONS.keys.sort)
  end

  describe '#transitioned_to_ethereum_enabled?' do
    it 'triggers if new token is saved with ethereum_enabled = true' do
      token = build(:token, ethereum_enabled: true)
      token.save!
      expect(token.transitioned_to_ethereum_enabled?).to eq(true)
    end

    it 'triggers if existing token is saved with ethereum_enabled = true' do
      token = create(:token, ethereum_enabled: false)
      token.update!(ethereum_enabled: true)
      expect(token.transitioned_to_ethereum_enabled?).to eq(true)
    end

    it 'does not trigger if new token is saved with ethereum_enabled = false' do
      token = build(:token, ethereum_enabled: false)
      token.save!
      expect(token.transitioned_to_ethereum_enabled?).to eq(false)
    end

    it 'is false if an existing token with an account is transitioned from ethereum_enabled = false to true' do
      stub_token_symbol
      token = create(:token, ethereum_enabled: false, ethereum_contract_address: '0x' + '7' * 40)
      token.update!(ethereum_enabled: true)
      expect(token.transitioned_to_ethereum_enabled?).to eq(false)
    end
  end

  it 'populate_token_symbol' do
    contract_address = '0xa8112e56eb96bd3da7741cfea0e3cbd841fc009d'
    stub_token_symbol
    token = create :token, symbol: nil, ethereum_contract_address: contract_address
    expect token.symbol = 'FCBB'
  end

  it 'set_predefined_values for coins' do
    %w[eth btc qtum ada eos xtz].each do |coin|
      token = create :token, coin_type: coin, name: nil
      expect(token.name).to eq Token::COIN_NAMES[coin.to_sym]
      expect(token.symbol).to eq coin.upcase
      expect(token.decimal_places).to eq Token::COIN_DECIMALS[coin.to_sym]
    end

    %w[qrc20 erc20].each do |token|
      expect((create :token, coin_type: token).name).to match(/Token/)
    end
  end

  it 'check_coin_type' do
    token = create :token, symbol: 'FCBB', decimal_places: 8, ethereum_contract_address: '0xa8112e56eb96bd3da7741cfea0e3cbd841fc009d', contract_address: 'a8112e56eb96bd3da7741cfea0e3cbd841fc009a', blockchain_network: 'qtum_testnet', coin_type: 'eth'
    expect(token).to be_valid
    expect(token.contract_address).to be_nil
    expect(token.ethereum_contract_address).to be_nil
    expect(token.symbol).to eq 'ETH'
    expect(token.decimal_places).to eq 18
    expect(token.blockchain_network).to be_nil
  end

  it 'can manual input symbol' do
    contract_address = '0xa8112e56eb96bd3da7741cfea0e3cbd841fc009d'
    stub_token_symbol
    token = create :token, symbol: 'AAA', ethereum_contract_address: contract_address
    expect token.symbol = 'AAA'
  end
end
