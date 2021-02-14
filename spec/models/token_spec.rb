require 'rails_helper'
require 'models/concerns/belongs_to_blockchain_spec'
require 'models/concerns/blockchain_transactable_spec'
require 'models/concerns/active_storage_validator_spec'

describe Token, type: :model, vcr: true do
  it_behaves_like 'belongs_to_blockchain'
  it_behaves_like 'blockchain_transactable'
  it_behaves_like 'active_storage_validator', ['logo_image']

  it { is_expected.to have_many(:projects) }
  it { is_expected.to have_many(:accounts) }
  it { is_expected.to have_many(:account_token_records) }
  it { is_expected.to have_many(:reg_groups) }
  it { is_expected.to have_many(:transfer_rules) }
  it { is_expected.to have_many(:blockchain_transactions) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:_token_type) }
  it { is_expected.to validate_presence_of(:denomination) }
  it { is_expected.to define_enum_for(:_token_type) }

  describe described_class.new do
    it { is_expected.to respond_to(:contract) }
    it { is_expected.to respond_to(:abi) }
  end

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

  describe 'denomination' do
    it 'should contain the platform wide currencies' do
      expect(described_class.denominations.map { |x, _| x }.sort).to eq(Comakery::Currency::DENOMINATIONS.keys.sort)
    end
  end

  describe 'set_values_from_token_type' do
    it 'loads values from token_type before validation' do
      token = Token.create!(_token_type: :btc, _blockchain: :bitcoin)

      expect(token.name).to eq("#{token.token_type&.name&.upcase} (#{token.blockchain&.name})")
      expect(token.symbol).to eq(token.token_type.symbol)
      expect(token.decimal_places).to eq(token.token_type.decimals)
    end

    context 'when custom values are provided' do
      it 'keeps the values' do
        attrs = {
          name: 'Dummy Coin',
          symbol: 'DMC',
          decimal_places: 2
        }

        token = Token.create!(_token_type: :btc, _blockchain: :bitcoin, **attrs)

        expect(token.name).to eq(attrs[:name])
        expect(token.symbol).to eq(attrs[:symbol])
        expect(token.decimal_places).to eq(attrs[:decimal_places])
      end
    end

    context 'when provided contract address is incorrect' do
      it 'adds an error' do
        expect(described_class.new(_token_type: :erc20, _blockchain: :ethereum_ropsten, contract_address: '1').valid?).to be_falsey
      end
    end
  end

  describe 'token' do
    subject { described_class.new }
    specify { expect(subject.token).to eq(subject) }
  end

  describe 'token_type' do
    it 'returns a TokenType instance' do
      expect(described_class.new.token_type).to be_a(TokenType::Btc)
    end
  end

  describe 'abi' do
    let!(:comakery_token) { create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten) }
    let!(:token) { create(:token, _token_type: 'erc20', _blockchain: :ethereum_ropsten, contract_address: build(:ethereum_contract_address)) }

    it 'returns correct abi for Comakery Token' do
      expect(comakery_token.abi.last['name']).to eq('safeApprove')
    end

    it 'returns default abi for other tokens' do
      expect(token.abi.last['name']).to eq('Transfer')
    end
  end

  describe 'to_base_unit' do
    it 'converts an amount from BigDecimal into a Integer base unit based on token decimals' do
      expect(create(:token, decimal_places: 18).to_base_unit(BigDecimal(1) + 0.1)).to eq(1100000000000000000)
      expect(create(:token, decimal_places: 2).to_base_unit(BigDecimal(1) + 0.1)).to eq(110)
      expect(create(:token, decimal_places: 0).to_base_unit(BigDecimal(1) + 0.1)).to eq(1)
    end
  end

  describe 'from_base_unit' do
    it 'converts an amount from base unit into a BigDecimal based on token decimals' do
      expect(create(:token, decimal_places: 18).from_base_unit(1100000000000000000)).to eq(BigDecimal(1) + 0.1)
      expect(create(:token, decimal_places: 2).from_base_unit(110)).to eq(BigDecimal(1) + 0.1)
      expect(create(:token, decimal_places: 0).from_base_unit(1)).to eq(BigDecimal(1))
    end
  end

  describe 'default_reg_group' do
    it 'returns default reg group for token' do
      expect(create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten).default_reg_group).to be_a(RegGroup)
    end
  end
end
