require 'rails_helper'

describe Attachment::GetPath do
  context 'attachment exists' do
    let(:image) { create(:account, image: dummy_image).image }

    it 'succeeds' do
      regexp = %r{rails\/active_storage\/blobs\/.+\/dummy_image\.png}
      result = Attachment::GetPath.call(attachment: image)
      expect(result.success?).to eq(true)
      expect(result.path).to match(regexp)
    end
  end

  context 'attachment does not exist' do
    let(:image) { create(:account, image: nil).image }

    it 'fails' do
      result = Attachment::GetPath.call(attachment: image)
      expect(result.success?).to eq(false)
      expect(result.message).to eq('There is no attachment')
      expect(result.path).to eq(nil)
    end
  end
end
