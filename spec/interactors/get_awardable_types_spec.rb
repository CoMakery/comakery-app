require 'rails_helper'

describe GetAwardableTypes do
  describe '#call' do
    describe 'awardable_types' do
      it 'returns [] if no account' do
        expect(described_class.call(account: nil).awardable_types).to eq([])
      end
    end

    describe 'can_award' do
      let!(:team1) { create :team }
      let!(:team2) { create :team }
      let!(:owner) { create(:account) }
      let!(:authentication) { create :authentication, account: owner, updated_at: 1.day.ago }

      let!(:swarmbot_only_account) { create(:account) }
      let!(:swarmbot_only_auth) { create :authentication, account: swarmbot_only_account }

      let!(:citizencode_project) do
        create(:project, account: owner).tap do |p|
          create(:award_type, project: p, community_awardable: false)
        end
      end
      let!(:swarmbot_project) do
        create(:project, account: swarmbot_only_account).tap do |p|
          create(:award_type, project: p, community_awardable: false)
        end
      end
      let!(:other_project) { create(:project, visibility: 'public_listed') }

      before do
        team1.build_authentication_team authentication
        team2.build_authentication_team swarmbot_only_auth
      end

      it "returns true if you are an owner of the project and your slack_auth slack_team_id is the same as the project's" do
        expect(described_class.call(project: citizencode_project, account: owner).can_award).to be_truthy
      end

      it "returns true if account's slack auth is the same as the project and the project has community awardable awards" do
        create(:award_type, project: swarmbot_project, community_awardable: true)

        expect(described_class.call(project: swarmbot_project, account: swarmbot_only_account).can_award).to be_truthy
      end

      it 'returns false otherwise' do
        expect(AwardType.where(community_awardable: true)).to be_empty

        expect(described_class.call(project: nil, account: owner).can_award).to be_falsey

        expect(described_class.call(project: citizencode_project, account: nil).can_award).to be_falsey
        expect(described_class.call(project: citizencode_project, account: swarmbot_only_account).can_award).to be_falsey
        expect(described_class.call(project: swarmbot_project, account: owner).can_award).to be_falsey
        expect(described_class.call(project: swarmbot_project, account: swarmbot_only_account).can_award).to be_truthy

        expect(described_class.call(project: other_project, account: owner).can_award).to be_falsey
        expect(described_class.call(project: other_project, account: swarmbot_only_account).can_award).to be_falsey
      end
    end
  end
end
