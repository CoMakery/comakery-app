require 'rails_helper'

describe Attachment::SetFallbackPath do
  context 'fallback given' do
    it 'sets rails path to given image' do
      result = Attachment::SetFallbackPath.call(fallback: 'test.jpg')
      expect(result.success?).to be(true)
      expect(result.path).to eq('test.jpg')
    end
  end

  context 'fallback is not given' do
    it 'does not modify path' do
      result = Attachment::SetFallbackPath.call
      expect(result.success?).to be(true)
      expect(result.path).to eq(nil)
    end
  end
end
