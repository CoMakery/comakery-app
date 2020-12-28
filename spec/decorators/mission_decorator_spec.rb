require 'rails_helper'

describe MissionDecorator do
  describe 'header_props' do
    let(:mission) { create(:mission) }

    it 'includes required data for project header component' do
      props = mission.decorate.header_props

      expect(props[:name]).to eq(mission.name)
      expect(props[:url]).to include(mission.id.to_s)
      expect(props[:image_url]).to include('dummy_image.png')
    end
  end
end
