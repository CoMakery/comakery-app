shared_examples 'active_storage_validator' do |attrs|
  CONTENT_TYPE = %w[image/png image/jpg image/jpeg]

  attrs.each do |attr|
    it { is_expected.to validate_content_type_of(attr.to_sym).allowing(CONTENT_TYPE) }
    it { is_expected.to validate_size_of(attr.to_sym).less_than(10.megabytes) }
  end
end
