require 'rails_helper'

RSpec.describe Interest, type: :model do
  describe 'add_airtable' do
    it 'add record to airtable on create' do
      stub_airtable
      account = create :account
      create :interest, account: account, protocol: 'Vevue', project: 'Promotion'
      expect(account.interested?('Vevue', 'Promotion')).to be_truthy
    end
  end
end
