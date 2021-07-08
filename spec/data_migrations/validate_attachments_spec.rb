require 'rails_helper'
require Rails.root.join('db/data_migrations/20210114220605_validate_attachments')

describe ValidateAttachments do
  subject { described_class.new.up }

  it 'do not remove valid images' do
    token = create(:token, logo_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary))
    mission = create(:mission, image: fixture_file_upload('helmet_cat.png', 'image/png', :binary))

    expect(token.reload.logo_image.attached?).to be true
    expect(mission.reload.image.attached?).to be true
    subject
    expect(token.reload.logo_image.attached?).to be true
    expect(mission.reload.image.attached?).to be true
  end

  it 'removes attachments with invalid content_type' do
    # disable image processing
    allow_any_instance_of(ImagePreparer).to receive(:valid?).and_return(true)
    allow_any_instance_of(ImagePreparer).to receive(:attachment).and_return(fixture_file_upload('mario-running.gif', 'image/gif', :binary))

    token_invalid_logo = create(:token, logo_image: fixture_file_upload('mario-running.gif', 'image/gif', :binary))

    expect(token_invalid_logo.reload.logo_image.attached?).to be true
    subject
    expect(token_invalid_logo.reload.logo_image.attached?).to be false
  end
end
