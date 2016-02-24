require 'rails_helper'

describe Account do
  subject(:account) { create :account, password: "12345678" }
  let(:role1) { create :role, name: 'Fun 1' }
  let(:role2) { create :role, name: 'Fun 2' }

  describe "validations" do
    it "requires many attributes" do
      expect(Account.new.tap{|a|a.valid?}.errors.full_messages.sort).to eq(["Email can't be blank", "Name can't be blank"])
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

  describe "#slack_auth" do
    let!(:slack_authentication) { create(:authentication, provider: 'slack', account: subject)}
    let!(:other_authentication) { create(:authentication, provider: 'other', account: subject)}

    it "returns the authentication associated with this account that is from the 'slack' provider" do
      expect(subject.slack_auth).to eq(slack_authentication)
    end
  end
end
