require 'rails_helper'

RSpec.describe ImagePreparer do
  subject { described_class.new(attr_name, attachment, options) }

  let(:attr_name) { 'image' }
  let(:options) { nil }

  context 'strip EXIF for jpeg' do
    let(:attachment) { fixture_file_upload('image_with_exif.jpg', 'image/jpg', :binary) }

    specify do
      tmp_img_file_path = attachment.path
      initial_img = MiniMagick::Image.open(tmp_img_file_path)
      expect(initial_img.exif.count).to eq 50

      expect(subject.valid?).to be true

      prepared_img = MiniMagick::Image.open(tmp_img_file_path)
      expect(prepared_img.exif.count).to eq 0
    end
  end

  context 'resize' do
    let(:attr_name) { 'square_image' }
    let(:attachment) { fixture_file_upload('helmet_cat.png', 'image/png', :binary) }
    let(:options) { { resize: '50x50!' } }

    specify 'works' do
      tmp_img_file_path = attachment.path
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
      let!(:attachment) { fixture_file_upload('helmet_cat.png', 'image/png', :binary) }

      it { expect(subject.valid?).to be true }
    end

    context 'when params contain attachments with pixel bomb' do
      let!(:attachment) { fixture_file_upload('lottapixel.jpg', 'image/jpg', :binary) }

      it 'fails and returns an error' do
        expect(subject.valid?).to be false
        expect(subject.attachment).to be nil
        expect(subject.error).to eq 'exceeds maximum pixel dimensions'
      end
    end

    context 'when params has too big image' do
      let!(:attachment) { fixture_file_upload('heavy_image.png', 'image/png', :binary) }

      it 'fails and returns an error' do
        expect(subject.valid?).to be(false)
        expect(subject.attachment).to be nil
        expect(subject.error).to eq 'has too big size'
      end
    end
  end
end
