require 'rails_helper'

RSpec.describe OreIdSyncJob, type: :job do
  subject { create(:ore_id) }

  specify do
    expect_any_instance_of(subject.service.class).to receive(:create_remote)
    described_class.perform_now(subject.id)
  end
end
