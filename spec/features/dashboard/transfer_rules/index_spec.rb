require 'rails_helper'
require 'features/dashboard/wallet_connect_spec'

describe 'project transfer rules page' do
  it_behaves_like 'having wallet connect button', { path_helper: :project_dashboard_transfer_rules_path, requires_token: true }
end
