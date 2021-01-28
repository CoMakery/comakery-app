require 'rails_helper'

describe 'rake whitelabel_mission:create_default', type: :task do
  let(:wl_var) { 'true' }
  let(:app_host_var) { 'wl.mission.test' }

  around(:each) do |example|
    prev_wl_env = ENV['WHITELABEL']
    prev_app_host_env = ENV['APP_HOST']

    ENV['WHITELABEL'] = wl_var
    ENV['APP_HOST'] = app_host_var

    example.run

    ENV['WHITELABEL'] = prev_wl_env
    ENV['APP_HOST'] = prev_app_host_env
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  context 'with WHITELABEL not set' do
    let(:wl_var) { nil }

    it 'exit gracefully without creating mission' do
      expect { task.execute }.to raise_error SystemExit
      expect(Mission.count).to be_zero
    end
  end

  context 'with WHITELABEL != true' do
    let(:wl_var) { 'false' }

    it 'exit gracefully without creating mission' do
      expect { task.execute }.to raise_error SystemExit
      expect(Mission.count).to be_zero
    end
  end

  it 'create a default WL mission' do
    task.execute
    mission = Mission.last
    expect(mission).to be_present
    expect(mission.whitelabel).to be true
    expect(mission.whitelabel_domain).to eq app_host_var
  end
end
