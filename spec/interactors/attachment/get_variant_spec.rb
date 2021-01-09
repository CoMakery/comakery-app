require 'rails_helper'

describe Attachment::GetVariant do
  context 'attachment exists' do
    let(:image) { create(:account, image: dummy_image).image }

    context 'without resize option' do
      it 'succeeds' do
        result = Attachment::GetVariant.call(attachment: image)
        expect(result.success?).to eq(true)
        expect(result.variant).to be_a_kind_of(ActiveStorage::Variant)
      end
    end

    context 'with resize option' do
      it 'succeeds' do
        resize_method = %i[resize_to_fill resize_to_fit resize_to_limit].sample
        result = Attachment::GetVariant.call(
          attachment: image,
          resize_method => [100, 100]
        )
        expect(result.success?).to eq(true)
        expect(result.variant).to be_a_kind_of(ActiveStorage::Variant)
      end
    end
  end

  context 'attachment does not exist' do
    let(:image) { create(:account, image: nil).image }

    it 'fails' do
      result = Attachment::GetVariant.call(attachment: image)
      expect(result.success?).to eq(false)
      expect(result.message).to eq('There is no attachment')
      expect(result.variant).to eq(nil)
    end
  end
end
