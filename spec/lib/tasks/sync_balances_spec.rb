require 'rails_helper'

describe 'rake balances:sync_all', type: :task do
  it 'runs the sync job' do
    expect(SyncBalancesJob).to receive(:perform_now).at_least(:once)
    task.execute
  end
end
