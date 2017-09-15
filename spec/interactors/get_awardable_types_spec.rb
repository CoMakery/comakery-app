require 'rails_helper'

describe GetAwardableTypes do
  describe '#call' do
    describe 'awardable_types' do
      it 'returns [] if no account' do
        expect(described_class.call(current_account: nil).awardable_types).to eq([])
      end
    end

    describe 'can_award' do
      let!(:owner) do
        create(:account).tap do |a|
          create(:authentication, account: a, slack_team_id: 'citizencode', updated_at: 1.day.ago)
          create(:authentication, account: a, slack_team_id: 'swarmbot', updated_at: 2.days.ago)
        end
      end
      let!(:swarmbot_only_account) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: 'swarmbot') } }

      let!(:citizencode_project) do
        create(:project, owner_account: owner, slack_team_id: 'citizencode').tap do |p|
          create(:award_type, project: p, community_awardable: false)
        end
      end
      let!(:swarmbot_project) do
        create(:project, owner_account: owner, slack_team_id: 'swarmbot').tap do |p|
          create(:award_type, project: p, community_awardable: false)
        end
      end
      let!(:other_project) { create(:project, public: true) }

      it "returns true if you are an owner of the project and your slack_auth slack_team_id is the same as the project's" do
        expect(described_class.call(project: citizencode_project, current_account: owner).can_award).to be_truthy
      end

      it "returns true if account's slack auth is the same as the project and the project has community awardable awards" do
        create(:award_type, project: swarmbot_project, community_awardable: true)

        expect(described_class.call(project: swarmbot_project, current_account: swarmbot_only_account).can_award).to be_truthy
      end

      it 'returns false otherwise' do
        expect(AwardType.where(community_awardable: true)).to be_empty

        expect(described_class.call(project: nil, current_account: owner).can_award).to be_falsey

        expect(described_class.call(project: citizencode_project, current_account: nil).can_award).to be_falsey
        expect(described_class.call(project: citizencode_project, current_account: swarmbot_only_account).can_award).to be_falsey
        expect(described_class.call(project: swarmbot_project, current_account: owner).can_award).to be_falsey
        expect(described_class.call(project: swarmbot_project, current_account: swarmbot_only_account).can_award).to be_falsey

        expect(described_class.call(project: other_project, current_account: owner).can_award).to be_falsey
        expect(described_class.call(project: other_project, current_account: swarmbot_only_account).can_award).to be_falsey
      end
    end
  end
end
