require 'rails_helper'

RSpec.describe Interest, type: :model do
  it { is_expected.to belong_to(:specialty) }

  describe 'add_airtable' do
    it 'add record to airtable on create' do
      ENV['AIRTABLE_SIGNUPS_TABLE_ID'] = '123qwer'
      stub_airtable
      account = create :account
      project = create :project
      create :interest, account: account, protocol: 'Vevue', project_id: project.id
      expect(account.interested?(project.id)).to be_truthy
    end
  end
end
