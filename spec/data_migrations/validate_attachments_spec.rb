require 'rails_helper'
require Rails.root.join('db/data_migrations/20210114220605_validate_attachments')

describe ValidateAttachments do
  subject { described_class.new.up }

  let(:token) { create(:token, logo_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary)) }
  let(:mission) { create(:mission, image: fixture_file_upload('helmet_cat.png', 'image/png', :binary)) }
  let(:token_invalid_logo) { create(:token, logo_image: fixture_file_upload('mario-running.gif', 'image/gif', :binary)) }

  it 'removes attachments with invalid content_type' do
    subject

    expect(token_invalid_logo.logo_image.attached?).to be false
    expect(token.reload.logo_image.attached?).to be true
  end
end
