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
    let(:award_type) { create :award_type }

    it 'returns true if project is editable by account' do
      expect(described_class.new(award_type.project.account, award_type.awards.new).create?).to be true
    end

    it 'returns false if project is not editable by account' do
      expect(described_class.new(create(:account), award_type.awards.new).create?).to be false
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

  describe 'edit?' do
    let!(:award_editable) { create(:award_ready) }
    let!(:award_non_editable) { create(:award) }

    it 'returns true if award is editable and project is editable by account' do
      expect(described_class.new(award_editable.project.account, award_editable).edit?).to be true
    end

    it 'returns false if project is not editable by account' do
      expect(described_class.new(create(:account), award_editable).edit?).to be false
    end

    it 'returns false if award is not editable' do
      expect(described_class.new(award_non_editable.project.account, award_non_editable).edit?).to be false
    end
  end

  describe 'assign?' do
    let!(:award_assignable) { create(:award_ready) }
    let!(:award_non_assignable) { create(:award) }

    it 'returns true if award can be assigned and project is editable by account' do
      expect(described_class.new(award_assignable.project.account, award_assignable).assign?).to be true
    end

    it 'returns false if project is not editable by account' do
      expect(described_class.new(create(:account), award_assignable).assign?).to be false
    end

    it 'returns false if award cannot be assigned' do
      expect(described_class.new(award_non_assignable.project.account, award_non_assignable).assign?).to be false
    end
  end

  describe 'start?' do
    it 'returns true if award is ready, and related to account' do
      a = create(:award, status: 'ready')
      expect(described_class.new(a.project.account, a).start?).to be true
    end

    it 'returns true if award is invite_ready, and related to account' do
      a = create(:award, status: 'invite_ready')
      expect(described_class.new(a.project.account, a).start?).to be true
    end

    it 'returns true if award is ready, has matching experience and accessable for a given user' do
      award = create(
        :award_ready,
        experience_level: Award::EXPERIENCE_LEVELS['New Contributor'],
        specialty: create(:specialty),
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
    it 'returns true if award is submitted and project is editable by account' do
      a = create(:award, status: 'submitted')
      expect(described_class.new(a.project.account, a).review?).to be true
    end

    it 'returns false if project is not editable by account' do
      a = create(:award, status: 'submitted')
      expect(described_class.new(create(:account), a).review?).to be false
    end

    it 'returns false if award is not submitted' do
      a = create(:award)
      expect(described_class.new(a.issuer, a).review?).to be false
    end
  end

  describe 'pay?' do
    it 'returns true if award is accepted and project is editable by account' do
      a = create(:award, status: 'accepted')
      expect(described_class.new(a.project.account, a).pay?).to be true
    end

    it 'returns false if project is not editable by account' do
      a = create(:award, status: 'accepted')
      expect(described_class.new(create(:account), a).pay?).to be false
    end

    it 'returns false if award is not accepted' do
      a = create(:award, status: 'started')
      expect(described_class.new(a.issuer, a).pay?).to be false
    end
  end

  describe 'project_editable?' do
    let(:project_admin) { create :account }
    let(:project) { create :project }
    let(:award) { create :award, award_type: create(:award_type, project: project) }

    before do
      project.admins << project_admin
    end

    specify { expect(described_class.new(project_admin, award).project_editable?).to be_truthy }
    specify { expect(described_class.new(project.account, award).project_editable?).to be_truthy }
    specify { expect(described_class.new(create(:account), award).project_editable?).to be_falsey }
    specify { expect(described_class.new(nil, award).project_editable?).to be_falsey }
  end
end
