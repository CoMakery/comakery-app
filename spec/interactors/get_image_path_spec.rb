require 'rails_helper'

describe GetImagePath do
  context 'attachment exists' do
    let(:image) { create(:account, image: dummy_image).image }

    it 'succeeds' do
      result = GetImagePath.call(attachment: image)

      expect(result.success?).to be(true)
      expect(result.path).not_to be(nil)
    end
  end

  context 'attachment does not exist' do
    let(:image) { create(:account, image: nil).image }

    context 'fallback given' do
      it 'fails but returns fallback path' do
        result = GetImagePath.call(attachment: image, fallback: 'test.jpg')

        expect(result.success?).to be(false)
        expect(result.path).not_to be(nil)
      end
    end

    context 'fallback not given' do
      it 'fails but returns fallback path' do
        result = GetImagePath.call(attachment: image)

        expect(result.success?).to be(false)
        expect(result.path).to be(nil)
      end
    end
  end
end
