require 'rails_helper'

RSpec.describe AccountTokenRecordDecorator do
  describe 'lockup_until_pretty' do
    let!(:account_token_record_max_lockup) { create(:account_token_record, lockup_until: AccountTokenRecord::LOCKUP_UNTIL_MAX) }
    let!(:account_token_record_min_lockup) { create(:account_token_record, lockup_until: AccountTokenRecord::LOCKUP_UNTIL_MIN) }
    let!(:account_token_record) { create(:account_token_record) }

    it 'returns "∞" if value is max' do
      expect(account_token_record_max_lockup.decorate.lockup_until_pretty).to eq('∞')
    end

    it 'returns "none" if value is min' do
      expect(account_token_record_min_lockup.decorate.lockup_until_pretty).to eq('None')
    end

    it 'returns formatted date' do
      expect(account_token_record.decorate.lockup_until_pretty).to eq(account_token_record.lockup_until.strftime('%b %e, %Y'))
    end
  end
end
