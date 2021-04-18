require 'rails_helper'

RSpec.describe ImagePixelValidator do
  subject { described_class.new(project, params) }

  let!(:project) { create(:project) }

  context 'when params contain valid attachments' do
    let!(:params) do
      ActionController::Parameters.new(
        {
          square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
          panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary)
        }
      ).permit!
    end

    it { expect(subject.valid?).to be(true) }
  end

  context 'when params contain attachments with pixel bomb' do
    let!(:params) do
      ActionController::Parameters.new(
        {
          square_image: fixture_file_upload('lottapixel.jpg', 'image/jpg', :binary),
          panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary)
        }
      ).permit!
    end

    it 'fails and returns an error' do
      expect(subject.valid?).to be(false)

      expect(project.errors.full_messages).to eq(['Square image exceeds maximum pixel dimensions'])
    end
  end
end
