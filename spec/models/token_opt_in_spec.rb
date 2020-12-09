require 'rails_helper'

RSpec.describe TokenOptIn, type: :model do
  let(:token_opt_in) { create(:token_opt_in) }

  it { is_expected.to belong_to(:wallet) }
  it { is_expected.to belong_to(:token) }

  it { expect(token_opt_in).to validate_uniqueness_of(:wallet_id).scoped_to(:token_id) }
end
