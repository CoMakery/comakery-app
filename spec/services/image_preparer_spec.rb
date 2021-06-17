require 'rails_helper'

RSpec.describe ImagePreparer do
  subject { described_class.new(project, params) }

  let!(:project) { create(:project) }

  context 'strip EXIF for jpeg' do
    let!(:params) do
      ActionController::Parameters.new(
        { image: fixture_file_upload('image_with_exif.jpg', 'image/jpg', :binary) }
      ).permit!
    end

    specify do
      tmp_img_file_path = params['image'].tempfile.path
      initial_img = MiniMagick::Image.open(tmp_img_file_path)
      expect(initial_img.exif.count).to eq 50

      expect(subject.valid?).to be true

      prepared_img = MiniMagick::Image.open(tmp_img_file_path)
      expect(prepared_img.exif.count).to eq 0
    end
  end

  context 'resize' do
    subject { described_class.new(project, params, image: { resize: '50x50!' }) }

    let!(:params) do
      ActionController::Parameters.new(
        {
          image: fixture_file_upload('helmet_cat.png', 'image/png', :binary)
        }
      ).permit!
    end

    specify 'works' do
      tmp_img_file_path = params['image'].tempfile.path
      initial_img = MiniMagick::Image.open(tmp_img_file_path)
      expect(initial_img.width).to eq 256
      expect(initial_img.height).to eq 256

      expect(subject.valid?).to be true

      prepared_img = MiniMagick::Image.open(tmp_img_file_path)
      expect(prepared_img.width).to eq 50
      expect(prepared_img.height).to eq 50
    end
  end

  context '#valid?' do
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

    context 'when params has too big image' do
      let!(:params) do
        ActionController::Parameters.new(
          { image: fixture_file_upload('heavy_image.png', 'image/png', :binary) }
        ).permit!
      end

      it 'fails and returns an error' do
        expect(subject.valid?).to be(false)

        expect(project.errors.full_messages).to eq(['Image has too big size'])
      end
    end
  end
end
