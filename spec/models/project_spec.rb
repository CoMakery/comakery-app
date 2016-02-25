require 'rails_helper'

describe Project do
  describe 'validations' do
    it 'requires an owner' do
      expect(Project.new.tap(&:valid?).errors.full_messages.sort).to eq(["Owner account can't be blank",
                                                                         "Title can't be blank"])
    end

    it "requires the tracker url be valid if present" do
      project = Project.new(owner_account: create(:account), title: "title", tracker: "foo")
      expect(project).not_to be_valid
      expect(project.errors.full_messages).to eq(["Tracker must be a valid url"])
    end
  end

  describe 'associations' do
    it 'has many reward_types and accepts them as nested attributes' do
      project = Project.create!(
        title: 'This is a title',
        owner_account: create(:account),
        slack_team_id: '123',
        reward_types_attributes: [
          { 'name' => 'Small reward', 'suggested_amount' => '1000' },
          { 'name' => '', 'suggested_amount' => '1000' },
          { 'name' => 'Reward', 'suggested_amount' => '' }
        ])

      expect(project.reward_types.count).to eq(1)
      expect(project.reward_types.first.name).to eq('Small reward')
      expect(project.reward_types.first.suggested_amount).to eq(1000)
      expect(project.slack_team_id).to eq('123')

      project.update(reward_types_attributes: { id: project.reward_types.first.id, _destroy: true })
      expect(project.reward_types.count).to eq(0)
    end
  end

end
