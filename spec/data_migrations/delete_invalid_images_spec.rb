require 'rails_helper'
require Rails.root.join('db/data_migrations/20210702070447_delete_invalid_images')

describe DeleteInvalidImages do
  subject { described_class.new.up }

  let(:valid_image) { fixture_file_upload('helmet_cat.png', 'image/png', :binary) }
  let(:invalid_image) { fixture_file_upload('lottapixel.jpg', 'image/jpg', :binary) }
  let(:project) { FactoryBot.create(:project, image: valid_image, square_image: valid_image, panoramic_image: valid_image) }
  let(:account) { FactoryBot.create(:account, image: valid_image) }
  let(:mission) { FactoryBot.create(:mission, logo: valid_image, image: valid_image, whitelabel_logo: valid_image, whitelabel_logo_dark: valid_image, whitelabel_favicon: valid_image) }
  let(:token) { FactoryBot.create(:token, logo_image: valid_image) }
  let(:award) { create(:award, image: valid_image) }
  let(:award_type) { FactoryBot.create(:award_type, diagram: valid_image) }

  example 'delete invalid images' do
    # disable image processing and replace it to invalid image
    allow_any_instance_of(ImagePreparer).to receive(:valid?).and_return(true)
    allow_any_instance_of(ImagePreparer).to receive(:attachment).and_return(invalid_image)

    expect(project.image.attached?).to be true
    expect(project.square_image.attached?).to be true
    expect(project.panoramic_image.attached?).to be true

    expect(account.image.attached?).to be true
    expect(token.logo_image.attached?).to be true
    expect(award.image.attached?).to be true
    expect(award_type.diagram.attached?).to be true

    expect(mission.logo.attached?).to be true
    expect(mission.image.attached?).to be true
    expect(mission.whitelabel_logo.attached?).to be true
    expect(mission.whitelabel_logo_dark.attached?).to be true
    expect(mission.whitelabel_favicon.attached?).to be true

    subject

    project.reload
    expect(project.image.attached?).to be false
    expect(project.square_image.attached?).to be false
    expect(project.panoramic_image.attached?).to be false

    expect(account.reload.image.attached?).to be false
    expect(token.reload.logo_image.attached?).to be false
    expect(award.reload.image.attached?).to be false
    expect(award_type.reload.diagram.attached?).to be false

    mission.reload
    expect(mission.logo.attached?).to be false
    expect(mission.image.attached?).to be false
    expect(mission.whitelabel_logo.attached?).to be false
    expect(mission.whitelabel_logo_dark.attached?).to be false
    expect(mission.whitelabel_favicon.attached?).to be false
  end

  example 'do not delete valid images' do
    subject

    project.reload
    expect(project.image.attached?).to be true
    expect(project.square_image.attached?).to be true
    expect(project.panoramic_image.attached?).to be true

    expect(account.reload.image.attached?).to be true
    expect(token.reload.logo_image.attached?).to be true
    expect(award.reload.image.attached?).to be true
    expect(award_type.reload.diagram.attached?).to be true

    mission.reload
    expect(mission.logo.attached?).to be true
    expect(mission.image.attached?).to be true
    expect(mission.whitelabel_logo.attached?).to be true
    expect(mission.whitelabel_logo_dark.attached?).to be true
    expect(mission.whitelabel_favicon.attached?).to be true
  end
end
