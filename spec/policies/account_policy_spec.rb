require 'rails_helper'

describe AccountPolicy do
  let!(:team1) { create :team }
  let!(:team2) { create :team }
  let!(:team_foobar_account1) { create(:account).tap { |a| create(:authentication, account: a) } }
  let!(:team_foobar_account2) { create(:account).tap { |a| create(:authentication, account: a) } }
  let!(:team_fizzbuzz_account1) { create(:account).tap { |a| create(:authentication, account: a) } }

  before do
    team1.build_authentication_team team_foobar_account1.authentications.first
    team1.build_authentication_team team_foobar_account2.authentications.first
    team2.build_authentication_team team_fizzbuzz_account1.authentications.first
  end

  describe AccountPolicy::Scope do
    it 'returns accounts that belong to the same organization as the current user' do
      expect(AccountPolicy::Scope.new(team_foobar_account1, team1).resolve).to match_array([team_foobar_account1, team_foobar_account2])
    end

    it 'returns nothing if account is nil' do
      expect(AccountPolicy::Scope.new(nil, team1).resolve).to eq([])
    end
  end

  describe 'new?' do
    it 'user can signup' do
      expect(described_class.new(nil, nil).new?).to be_truthy
    end
  end

  describe 'destroy?' do
    let!(:account) { create :account }

    it "user can't delete account" do
      expect(described_class.new(account, nil).destroy?).to be_falsey
    end

    it 'admin can delete account' do
      role = create :admin_role
      account.roles << role
      expect(described_class.new(account, nil).destroy?).to be_truthy
    end
  end
end
