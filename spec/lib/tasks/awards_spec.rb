require 'rails_helper'

describe 'rake awards:expire', type: :task do
  let!(:expired_award) { create(:award, status: :started, expires_at: 1.day.ago) }
  let!(:expiring_award) { create(:award, status: :started, expires_at: 10.days.from_now, notify_on_expiration_at: 1.day.ago) }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no subscribers' do
    expect { task.execute }.not_to raise_error
  end

  it 'expires task and sends notifications' do
    task.execute
    expect(expired_award.reload.ready?).to be_truthy
  end
end
