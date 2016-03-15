require 'rails_helper'

describe AwardPolicy do
  let!(:account) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "lots of sweet awards") } }
  let!(:other_auth) { create(:authentication, account: account, slack_team_id: "other project") }

  let!(:project) { create(:project, owner_account: account, slack_team_id: "lots of sweet awards") }
  let!(:other_project) { create(:project, owner_account: account, slack_team_id: "other project") }

  let!(:public_project) { create(:project, owner_account: create(:account), slack_team_id: "public project", public: true) }
  let(:award_type_with_public_project) { create(:award_type, project: public_project) }
  let(:award_with_public_project) { create(:award, award_type: award_type_with_public_project) }

  let(:award_type_with_project) { create(:award_type, project: project) }
  let(:award_with_project) { build(:award, award_type: award_type_with_project, account: receiving_account) }

  let(:award_type_with_other_project) { create(:award_type, project: other_project) }
  let(:award_with_other_project) { build(:award, award_type: award_type_with_other_project, account: account) }

  let(:receiving_account) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "lots of sweet awards") } }

  let(:other_account) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "other team") } }
  let(:unowned_project) { create(:project, owner_account: other_account) }

  let(:different_team_account) { create(:account) }

  let(:award_type_for_unowned_project) { create(:award_type, project: unowned_project) }
  let(:award_for_unowned_project) { build(:award, award_type: award_type_for_unowned_project) }

  describe AwardPolicy::Scope do
    context "logged out" do
      it "returns the awards to a project that are public" do
        expect(AwardPolicy::Scope.new(nil, Award).resolve).to eq([award_with_public_project])
      end
    end

    context "logged in" do
      it "returns awards that belong to projects that the specified account belongs to" do
        award_with_project.save!
        award_for_unowned_project.save!
        expect(award_type_for_unowned_project.project.slack_team_id).not_to eq(project.slack_team_id)

        create(:authentication, slack_team_id: project.slack_team_id, account: account)

        awards = AwardPolicy::Scope.new(account, Award).resolve
        expect(awards).to match_array([award_with_project])
      end
    end
  end

  describe "create?" do
    it "returns true when the accounts belongs to a project, and the award belongs to a award_type that belongs to that project" do
      expect(AwardPolicy.new(account, award_with_project).create?).to be true
    end

    it "returns true when the accounts belongs to a project, and the award belongs to a award_type that belongs to that project" do
      expect(AwardPolicy.new(account, award_with_other_project).create?).to be true
    end

    it "returns false when no account" do
      expect(AwardPolicy.new(nil, build(:award, award_type: award_type_with_project)).create?).to be_falsey
    end

    it "returns false when the sending account doesn't own the project" do
      expect(AwardPolicy.new(different_team_account, build(:award, award_type: award_type_with_project, account: receiving_account)).create?).to be_falsey
    end

    it "returns false when the receiving account doesn't belong to the project" do
      expect(AwardPolicy.new(account, build(:award, award_type: award_type_with_project, account: other_account)).create?).to be_falsey
    end

    it "returns false when award doesn't have a award_type" do
      expect(AwardPolicy.new(account, build(:award, award_type: nil)).create?).to be false
    end

    it "returns false when the award_type on the award does not belong to the account's project" do
      expect(AwardPolicy.new(account, award_for_unowned_project).create?).to be false
    end
  end
end
