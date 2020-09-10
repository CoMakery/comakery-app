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
      stub_web3_fetch
      expect { described_class.create(contract_address: '111') }.to raise_error(ArgumentError)
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
    end

    describe '_token_type' do
      let(:attrs) { { symbol: 'CBB', decimal_places: 8, _blockchain: 'ethereum_ropsten', contract_address: 'a' * 40 } }

      it 'eq erc20' do
        token = create :token, attrs.merge(_token_type: 'erc20')
        expect(token).to be_valid
        expect(token.reload._token_type).to eq 'erc20'
        expect(token._blockchain).to eq 'ethereum_ropsten'
        expect(token.contract_address).to eq 'a' * 40
        expect(token.symbol).to eq 'CBB'
        expect(token.decimal_places).to eq 8
      end

      it 'eq eth' do
        token = create :token, attrs.merge(_token_type: 'eth')
        expect(token).to be_valid
        expect(token.reload._token_type).to eq 'eth'
        expect(token.contract_address).to be_nil
        expect(token._blockchain).to eq 'ethereum_ropsten'
        expect(token.symbol).to eq 'ETH'
        expect(token.decimal_places).to eq 18
      end

      it 'eq qrc20' do
        token = create :token, attrs.merge(_token_type: 'qrc20', _blockchain: :qtum)
        expect(token).to be_valid
        expect(token.reload._token_type).to eq 'qrc20'
        expect(token._blockchain).to eq 'qtum'
        expect(token.contract_address).to eq 'a' * 40
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
      let(:token) { create(:token, _token_type: 'qrc20') }
      let(:address) { 'b' * 40 }

      it 'valid qtum contract address' do
        expect(build(:token, _token_type: 'qrc20', contract_address: nil)).to be_valid
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
    end
  end

  describe 'associations' do
    let!(:token) { create(:token, _token_type: :comakery_security_token) }
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
      expect(token.reg_groups).to include(reg_group)
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
      stub_web3_fetch
      token = create(:token, ethereum_enabled: false, contract_address: '0x' + '7' * 40)
      token.update!(ethereum_enabled: true)
      expect(token.transitioned_to_ethereum_enabled?).to eq(false)
    end
  end

  it 'populate_token_symbol' do
    contract_address = '0xa8112e56eb96bd3da7741cfea0e3cbd841fc009d'
    stub_web3_fetch
    token = create :token, symbol: nil, contract_address: contract_address
    expect token.symbol = 'FCBB'
  end

  it 'set_predefined_values for coins' do
    %w[eth btc qtum ada eos xtz].each do |coin|
      token = create :token, _token_type: coin, name: nil
      expect(token.name).to eq Token::COIN_NAMES[coin.to_sym]
      expect(token.symbol).to eq coin.upcase
      expect(token.decimal_places).to eq Token::COIN_DECIMALS[coin.to_sym]
    end

    %w[qrc20 erc20].each do |token|
      expect((create :token, _token_type: token).name).to match(/Token/)
    end
  end

  it 'can manual input symbol' do
    contract_address = '0xa8112e56eb96bd3da7741cfea0e3cbd841fc009d'
    stub_web3_fetch
    token = create :token, symbol: 'AAA', contract_address: contract_address
    expect token.symbol = 'AAA'
  end

  describe 'abi' do
    let!(:comakery_token) { create(:token, _token_type: :comakery_security_token) }
    let!(:token) { create(:token) }

    it 'returns correct abi for Comakery Token' do
      expect(comakery_token.abi.last['name']).to eq('safeApprove')
    end

    it 'returns default abi for other tokens' do
      expect(token.abi.last['name']).to eq('Transfer')
    end
  end

  describe 'to_base_unit' do
    it 'converts an amount into base unit based on token decimals' do
      expect(create(:token, decimal_places: 18).to_base_unit(BigDecimal(1) + 0.1)).to eq(1100000000000000000)
      expect(create(:token, decimal_places: 2).to_base_unit(BigDecimal(1) + 0.1)).to eq(110)
      expect(create(:token, decimal_places: 0).to_base_unit(BigDecimal(1) + 0.1)).to eq(1)
    end
  end

  describe 'default_reg_group' do
    it 'returns default reg group for token' do
      expect(create(:token, _token_type: :comakery_security_token).default_reg_group).to be_a(RegGroup)
    end
  end
end
