module SpecHelpers
  def dummy_image
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/dummy_image.png').to_s, 'image/png')
  end
end
