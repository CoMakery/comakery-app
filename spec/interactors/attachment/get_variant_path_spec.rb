require 'rails_helper'

describe Attachment::GetVariantPath do
  context 'attachment exists' do
    let(:variant) do
      create(:account, image: dummy_image).image.variant(resize_to_fill: [100, 100])
    end

    it 'succeeds' do
      regexp = %r{rails\/active_storage\/representations\/.+\/dummy_image\.png}
      result = Attachment::GetVariantPath.call(variant: variant)
      expect(result.success?).to eq(true)
      expect(result.path).to match(regexp)
    end
  end

  context 'attachment does not exist' do
    let(:image) { create(:account, image: nil).image }

    it 'fails' do
      result = Attachment::GetVariantPath.call(variant: image)
      expect(result.success?).to eq(false)
      expect(result.message).to eq('There is no attachment')
      expect(result.path).to eq(nil)
    end
  end
end
