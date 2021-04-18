require 'rails_helper'

describe CreateAward do
  let!(:token) { create(:comakery_dummy_token) }
  let!(:account) { create(:account) }
  let!(:project) { create(:project, token: token, account: account) }
  let!(:award_type) { create(:award_type) }
  let!(:source_award) do
    create(:award_ready, award_type: award_type, project: project, image: fixture_file_upload('helmet_cat.png',
                                                                                              'image/png',
                                                                                              :binary))
  end
  let!(:award_params) do
    ActionController::Parameters.new(
      {
        name: 'award',
        amount: 1
      }
    ).permit!
  end

  context 'when data is valid' do
    subject(:result) do
      described_class.call(award_type: award_type, award_params: award_params, account: account, image_from_id: nil)
    end

    it { expect(result.success?).to be(true) }

    it { expect { result }.to change(Award, :count).by(1) }
  end

  context 'when passed image from source award' do
    context 'and action is authorized' do
      subject(:result) do
        described_class.call(award_type: award_type, award_params: award_params, account: account,
                             image_from_id: source_award.id)
      end

      it 'attaches image to award from source' do
        expect(result.success?).to be(true)

        expect(result.award.image.attached?).to be(true)
      end
    end

    context 'and action is unauthorized' do
      let!(:source_award) do
        create(:award, image: fixture_file_upload('helmet_cat.png', 'image/png', :binary))
      end

      subject(:result) do
        described_class.call(award_type: award_type, award_params: award_params, account: account,
                             image_from_id: source_award.id)
      end

      it 'doesn\'t attach an image to the award' do
        expect(result.success?).to be(true)

        expect(result.award.image.attached?).to be(false)
      end
    end
  end

  context 'when the attached image contains a pixel bomb' do
    let!(:award_params) do
      ActionController::Parameters.new(
        {
          name: 'award',
          amount: 1,
          image: fixture_file_upload('lottapixel.jpg', 'image/jpg', :binary)
        }
      ).permit!
    end

    subject(:result) do
      described_class.call(
        award_type: award_type,
        award_params: award_params,
        account: account,
        image_from_id: source_award.id
      )
    end

    it 'fails' do
      expect(result.success?).to be(false)

      expect(result.award.errors.full_messages).to eq(['Image exceeds maximum pixel dimensions'])
    end
  end

  context 'when data is invalid' do
    let!(:award_params) { ActionController::Parameters.new({}).permit! }

    subject(:result) do
      described_class.call(
        award_type: award_type,
        award_params: award_params,
        account: account,
        image_from_id: source_award.id
      )
    end

    it 'fails' do
      expect(result.success?).to be(false)

      expect(result.award.errors.full_messages).to eq(['Name can\'t be blank', 'Amount is not a number'])
    end
  end
end
