require 'rails_helper'

RSpec.describe BatchTransactable, type: :model do
  it { is_expected.to belong_to(:transaction_batch) }
  it { is_expected.to belong_to(:blockchain_transactable) }
end
