FactoryBot.define do
  factory :award do
    account
    transfer_type
    sequence(:name) { |n| "Award #{n}" }
    amount { 10 }
    image do
      Rack::Test::UploadedFile.new Rails.root.join('spec/fixtures/dummy_image.png').to_s, 'image/png'
    end
    # long_identifier {}
  end
end
