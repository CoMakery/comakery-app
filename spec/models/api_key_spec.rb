require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  it { is_expected.to belong_to(:api_authorizable) }
  it { is_expected.to validate_length_of(:key).is_equal_to(32) }
  it { is_expected.to validate_uniqueness_of(:api_authorizable_id).scoped_to(:api_authorizable_type) }

  it 'populates #key before validation' do
    expect(described_class.create.key).not_to be_nil
  end
end
