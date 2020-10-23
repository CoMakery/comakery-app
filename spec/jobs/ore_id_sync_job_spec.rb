require 'rails_helper'

RSpec.describe OreIdSyncJob, type: :job, vcr: true do
  subject { create(:ore_id) }

  before do
    described_class.perform_now(subject)
  end

  specify do
    expect(subject).to receive(:sync_wallets)
  end
end
