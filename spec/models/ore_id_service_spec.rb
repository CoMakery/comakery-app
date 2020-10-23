require 'rails_helper'

RSpec.describe OreIdService, type: :model, vcr: true do
  subject { described_class.new }

  describe '#create_account' do
    specify { subject.create_account(create(:account)) }
  end
end
