require 'rails_helper'

describe Project do
  describe 'validations' do
    it 'requires an owner' do
      expect(Project.new.tap(&:valid?).errors.full_messages.sort).to eq(["Owner account can't be blank",
                                                                         "Slack team can't be blank",
                                                                         "Slack team name can't be blank",
                                                                         "Title can't be blank",
                                                                        ])
    end

    describe "tracker" do
      it "is valid if tracker is a valid, absolute url" do
        project = Project.create!(owner_account: create(:account), title: "title", slack_team_id: "bar", slack_team_name: "baz", tracker: "http://foo.com")
        expect(project).to be_valid
        expect(project.tracker).to eq("http://foo.com")
      end

      it "requires the tracker url be valid if present" do
        project = Project.new(owner_account: create(:account), title: "title", slack_team_id: "bar", slack_team_name: "baz", tracker: "foo")
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(["Tracker must be a valid url"])
      end

      it "is valid with no tracker specified" do
        project = Project.new(owner_account: create(:account), title: "title", slack_team_id: "bar", slack_team_name: "baz", tracker: nil)
        expect(project).to be_valid
      end

      it "is valid if tracker is blank" do
        project = Project.create!(owner_account: create(:account), title: "title", slack_team_id: "bar", slack_team_name: "baz", tracker: "")
        expect(project).to be_valid
        expect(project.tracker).to be_nil
      end
    end
  end

  describe 'associations' do
    it 'has many reward_types and accepts them as nested attributes' do
      project = Project.create!(
          title: 'This is a title',
          owner_account: create(:account),
          slack_team_id: '123',
          slack_team_name: 'This is a slack team name',
          reward_types_attributes: [
              {'name' => 'Small reward', 'amount' => '1000'},
              {'name' => '', 'amount' => '1000'},
              {'name' => 'Reward', 'amount' => ''}
          ])

      expect(project.reward_types.count).to eq(1)
      expect(project.reward_types.first.name).to eq('Small reward')
      expect(project.reward_types.first.amount).to eq(1000)
      expect(project.slack_team_id).to eq('123')
      expect(project.slack_team_name).to eq('This is a slack team name')

      project.update(reward_types_attributes: {id: project.reward_types.first.id, _destroy: true})
      expect(project.reward_types.count).to eq(0)
    end
  end

  describe "#owner_slack_user_name" do
    let!(:owner) { create :account }
    let!(:authentication) { create :authentication, account: owner, slack_team_id: 'reds', slack_user_name: 'johnny' }
    let!(:project) { create :project, owner_account: owner, slack_team_id: 'reds' }

    it "returns the user name" do
      expect(project.owner_slack_user_name).to eq('johnny')
    end
  end
end
