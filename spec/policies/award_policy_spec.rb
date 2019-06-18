require 'rails_helper'

describe AwardPolicy do
  let!(:team) { create :team }
  let!(:account) { create(:account) }
  let!(:account_authentication) { create(:authentication, account: account) }

  let!(:project) { create(:project, account: account) }
  let!(:other_project) { create(:project, account: account) }
  let!(:channel) { create :channel, team: team, project: project, name: 'channel', channel_id: 'channel' }
  let!(:other_channel) { create :channel, team: team, project: other_project, name: 'other_channel', channel_id: 'other_channel' }
  let!(:public_project) { create(:project, account: create(:account), public: true) }
  let(:award_type_with_public_project) { create(:award_type, project: public_project) }
  let(:award_with_public_project) { create(:award, award_type: award_type_with_public_project) }

  let(:award_type_with_project) { create(:award_type, project: project) }
  let(:community_award_type_with_project) { create(:award_type, project: project, community_awardable: true) }
  let(:award_with_project) { build(:award, award_type: award_type_with_project, account: receiving_authentication.account, issuer: account, channel: channel) }

  let(:award_type_with_other_project) { create(:award_type, project: other_project) }
  let(:award_with_other_project) { build(:award, award_type: award_type_with_other_project, account: account, issuer: account, channel: other_channel) }

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
      it 'returns no awards' do
        expect(AwardPolicy::Scope.new(nil, Award).resolve).to eq([])
      end
    end

    context 'logged in' do
      it 'returns accounts accessable awards' do
        2.times { create(:award, account: account) }
        2.times { create(:award, issuer: account) }
        expect(AwardPolicy::Scope.new(account, Award).resolve).to match_array(account.accessable_awards)
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

  describe 'show?' do
    it 'returns if project is visible for user' do
      a = create(:award)
      a.project.update(visibility: 'public_listed')
      expect(described_class.new(create(:account), a).show?).to be true
    end

    it 'returns true if award is included in account accessable awards' do
      a = create(:award)
      expect(described_class.new(a.account, a).show?).to be true
    end

    it 'returns false if award is not included in account accessable awards and project is not visible for user' do
      expect(described_class.new(create(:account), create(:award)).show?).to be false
    end
  end

  describe 'start?' do
    it 'returns true if award is ready, and related to account' do
      a = create(:award, status: 'ready')
      expect(described_class.new(a.account, a).start?).to be true
    end

    it 'returns true if award is ready, has matching experience and accessable for a given user' do
      award = create(
        :award,
        status: 'ready',
        experience_level: Award::EXPERIENCE_LEVELS['New Contributor'],
        award_type: create(
          :award_type,
          project: create(
            :project,
            visibility: 'public_listed'
          )
        )
      )
      expect(described_class.new(create(:account), award).start?).to be true
    end

    it 'returns false if award has not matching experience for a given user' do
      award = create(
        :award,
        status: 'ready',
        experience_level: Award::EXPERIENCE_LEVELS['Established Contributor'],
        award_type: create(
          :award_type,
          project: create(
            :project,
            visibility: 'public_listed'
          )
        )
      )
      expect(described_class.new(create(:account), award).start?).to be false
    end

    it 'returns false if award is not accessable for a given user' do
      expect(described_class.new(create(:account), create(:award, status: 'ready')).start?).to be false
    end

    it 'returns false if award is not ready' do
      a = create(:award)
      expect(described_class.new(a.account, a).start?).to be false
    end
  end

  describe 'submit?' do
    it 'returns true if award is started by a given user' do
      a = create(:award, status: 'started')
      expect(described_class.new(a.account, a).submit?).to be true
    end

    it 'returns false if award is not associated with a given user' do
      expect(described_class.new(create(:account), create(:award, status: 'started')).submit?).to be false
    end

    it 'returns false if award is not started' do
      a = create(:award)
      expect(described_class.new(a.account, a).submit?).to be false
    end
  end

  describe 'review?' do
    it 'returns true if award is submitted and issued by a given user' do
      a = create(:award, status: 'submitted')
      expect(described_class.new(a.issuer, a).review?).to be true
    end

    it 'returns false if award is not issued by a given user' do
      a = create(:award, status: 'submitted')
      expect(described_class.new(create(:account), a).review?).to be false
    end

    it 'returns false if award is not submitted' do
      a = create(:award)
      expect(described_class.new(a.issuer, a).review?).to be false
    end
  end

  describe 'pay?' do
    it 'returns true if award is accepted and issued by a given user' do
      a = create(:award, status: 'accepted')
      expect(described_class.new(a.issuer, a).pay?).to be true
    end

    it 'returns false if award is not issued by a given user' do
      a = create(:award, status: 'accepted')
      expect(described_class.new(create(:account), a).pay?).to be false
    end

    it 'returns false if award is not accepted' do
      a = create(:award, status: 'started')
      expect(described_class.new(a.issuer, a).pay?).to be false
    end
  end
end
