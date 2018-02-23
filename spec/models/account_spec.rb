require 'rails_helper'

describe Account do
  subject(:account) { create :account, password: '12345678' }

  let(:role1) { create :role, name: 'Fun 1' }
  let(:role2) { create :role, name: 'Fun 2' }

  describe 'validations' do
    it 'requires many attributes' do
      expect(described_class.new.tap(&:valid?).errors.full_messages.sort).to eq(["Email can't be blank"])
    end

    it 'requires #ethereum_wallet to be a valid ethereum address' do
      expect(account.ethereum_wallet).to be_blank
      expect(account).to be_valid

      expect(account.tap { |a| a.update(ethereum_wallet: 'foo') }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: '0x') }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'a' * 39}") }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'a' * 41}") }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'g' * 40}") }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])

      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'a' * 40}") }).to be_valid
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'A' * 40}") }).to be_valid
    end
  end

  it 'can have roles' do
    account.roles = [role1, role2]
  end

  it 'enforces unique emails, case-insensitively' do
    alice1 = create :account, email: 'alice@example.com'
    expect { create :account, email: 'Alice@example.com' }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  # this is kind of unfortunate --
  # would be better with a "email-as-entered" field and
  # a separate lowercase "email-as-authenticated-username" field
  it 'makes emails all lowercase' do
    alice = create :account, email: 'ALICE@example.com'
    expect(alice.email).to eq('alice@example.com')
  end

  describe '#slack' do
    context 'creates a new Slack instance if none exists' do
      before do
        create :authentication, provider: 'slack', account: subject
        subject.instance_variable_set(:@slack, nil)
      end
      specify do
        expect(subject.slack).to be_instance_of Comakery::Slack
      end
    end

    context 'returns Slack instance if exists' do
      let!(:slack) { build :slack }

      before { subject.instance_variable_set(:@slack, slack) }
      specify do
        expect(subject.slack).to eq slack
      end
    end
  end

  describe '#slack_auth' do
    let!(:slack_authentication) { create(:authentication, provider: 'slack', account: subject) }
    let!(:other_authentication) { create(:authentication, provider: 'other', account: subject) }

    it "returns the authentication associated with this account that is from the 'slack' provider" do
      expect(subject.slack_auth).to eq(slack_authentication)
    end
  end

  describe '#send_award_notifications' do
    before do
      create :authentication, provider: 'slack', account: subject
    end
    it 'sends a Slack notification' do
      allow(subject.slack).to receive(:send_award_notifications)
      subject.send_award_notifications
      expect(subject.slack).to have_received(:send_award_notifications)
    end
  end

  describe 'authorize using password' do
    it 'should not accept invalid password' do
      expect(subject.authenticate('notright')).to be false
    end
    it 'should return account for valid password' do
      expect(subject.authenticate('12345678')).to eq subject
    end
  end
end
