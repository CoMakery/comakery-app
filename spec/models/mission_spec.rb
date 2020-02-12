require 'rails_helper'

describe Mission do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Description can't be blank",
                                  "Image can't be blank",
                                  "Logo can't be blank",
                                  "Name can't be blank",
                                  "Subtitle can't be blank"
                                ])
    end

    it 'raises error if the attribute is too long' do
      errors = described_class.new(name: 'a' * 101, subtitle: 'a' * 141, description: 'a' * 501).tap(&:valid?).errors.full_messages
      expect(errors).to include('Name is too long (maximum is 100 characters)')
      expect(errors).to include('Subtitle is too long (maximum is 140 characters)')
      expect(errors).to include('Description is too long (maximum is 500 characters)')
    end

    it 'doesnt allow to overwrite whitelabel_api_public_key' do
      mission_w_public_key = create(:mission, whitelabel_api_public_key: build(:api_public_key))
      mission_wo_public_key = create(:mission)

      mission_w_public_key.whitelabel_api_public_key = 'updated'
      mission_wo_public_key.whitelabel_api_public_key = 'updated'

      expect(mission_w_public_key).not_to be_valid
      expect(mission_wo_public_key).to be_valid
    end
  end

  describe '#stats' do
    it 'returns number of not archived projects' do
      mission = create(:mission)
      create(:project, mission: mission)
      create(:project, mission: mission, visibility: :archived)

      expect(mission.stats[:projects]).to eq(1)
    end

    it 'returns number of published batches' do
      mission = create(:mission)
      create(:award_type, project: create(:project, mission: mission))
      create(:award_type, state: :draft, project: create(:project, mission: mission))

      expect(mission.stats[:batches]).to eq(1)
    end

    it 'returns number of tasks in progress' do
      mission = create(:mission)
      create(:award_ready, award_type: create(:award_type, project: create(:project, mission: mission)))
      create(:award, status: :paid, award_type: create(:award_type, project: create(:project, mission: mission)))

      expect(mission.stats[:tasks]).to eq(1)
    end

    it 'returns number of uniq accounts which have interest, started a task or created a project' do
      mission = create(:mission)
      project = create(:project, mission: mission, visibility: :public_listed)
      create(:award, award_type: create(:award_type, project: project))
      create(:interest, project: project, account: project.account)
      create(:interest, project: project)

      expect(mission.stats[:interests]).to eq(3)
    end
  end

  describe 'managed_accounts' do
    let!(:mission) { create(:mission) }
    let!(:account) { create(:account, managed_mission: mission) }

    it 'has many managed_accounts' do
      expect(mission.managed_accounts).to eq([account])
    end
  end

  describe 'populate_api_key' do
    let!(:mission_wo_key) { create(:mission, whitelabel: true) }
    let!(:mission_w_key) { create(:mission, whitelabel: true, whitelabel_api_key: '12345') }

    it 'populates whitelabel_api_key for whitelabel missions' do
      expect(mission_wo_key.whitelabel_api_key).not_to be_nil
    end

    it 'doesnt populate whitelabel_api_key for whitelabel missions if its present' do
      expect(mission_w_key.whitelabel_api_key).to eq('12345')
    end
  end
end
