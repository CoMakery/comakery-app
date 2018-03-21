require 'rails_helper'

describe AwardPolicy do
  let!(:team) { create :team }
  let!(:account) { create(:account) }
  let!(:account_authentication) { create(:authentication, account: account) }

  let!(:project) { create(:project, account: account) }
  let!(:other_project) { create(:project, account: account) }

  let!(:public_project) { create(:project, account: create(:account), public: true) }
  let(:award_type_with_public_project) { create(:award_type, project: public_project) }
  let(:award_with_public_project) { create(:award, award_type: award_type_with_public_project) }

  let(:award_type_with_project) { create(:award_type, project: project) }
  let(:community_award_type_with_project) { create(:award_type, project: project, community_awardable: true) }
  let(:award_with_project) { build(:award, award_type: award_type_with_project, account: receiving_authentication.account, issuer: account) }

  let(:award_type_with_other_project) { create(:award_type, project: other_project) }
  let(:award_with_other_project) { build(:award, award_type: award_type_with_other_project, account: account, issuer: account) }

  let(:receiving_authentication) { create(:authentication) }

  let(:other_authentication) { create(:authentication) }
  let(:unowned_project) { create(:project, account: other_authentication.account) }

  let(:different_team_authentication) { create(:authentication) }

  let(:award_type_for_unowned_project) { create(:award_type, project: unowned_project) }
  let(:award_for_unowned_project) { build(:award, award_type: award_type_for_unowned_project) }

  before do
    team.build_authentication_team account_authentication
    team.build_authentication_team receiving_authentication
  end

  describe AwardPolicy::Scope do
    context 'logged out' do
      it 'returns the awards to a project that are public' do
        expect(AwardPolicy::Scope.new(nil, Award).resolve).to eq([award_with_public_project])
      end
    end

    context 'logged in' do
      it 'returns awards that belong to projects that the specified account belongs to' do
        award_with_project.save!
        award_for_unowned_project.save!
        expect(award_type_for_unowned_project.project.teams).not_to include(team)

        auth = create(:authentication)
        team.build_authentication_team auth

        awards = AwardPolicy::Scope.new(account, Award).resolve
        expect(awards).to match_array([award_with_project])
      end
    end
  end

  describe 'create?' do
    it 'returns true when the accounts belongs to a project, and the award belongs to a award_type that belongs to that project' do
      expect(described_class.new(account, award_with_project).create?).to be true
    end

    it 'returns false when no account' do
      expect(described_class.new(nil, build(:award, award_type: award_type_with_project))).not_to be_create
    end

    it "returns false when the sending account doesn't own the project and award type is NOT community awardable" do
      expect(described_class.new(different_team_authentication, build(:award, award_type: award_type_with_project, account: receiving_authentication.account))).not_to be_create
    end

    it 'returns true when the sending account is the owner or award type is community awardable and the issuer is NOT the receiver' do
      expect(described_class.new(receiving_authentication.account, build(:award, award_type: community_award_type_with_project, account: receiving_authentication.account))).not_to be_create
      expect(described_class.new(receiving_authentication.account, build(:award, award_type: community_award_type_with_project, account: account, issuer: receiving_authentication.account)).create?).to eq(true)
    end

    it "returns false when the receiving account doesn't belong to the project" do
      expect(described_class.new(account, build(:award, award_type: award_type_with_project, account: other_authentication.account))).not_to be_create
    end

    it "returns false when award doesn't have a award_type" do
      expect(described_class.new(account, build(:award, award_type: nil))).not_to be_create
    end

    it "returns false when the award_type on the award does not belong to the account's project" do
      expect(described_class.new(account, award_for_unowned_project)).not_to be_create
    end
  end
end
