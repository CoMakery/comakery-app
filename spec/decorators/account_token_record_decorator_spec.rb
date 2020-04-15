require 'rails_helper'

RSpec.describe AccountTokenRecordDecorator do
  describe 'lockup_until_pretty' do
    let!(:account_token_record_max_lockup) { create(:account_token_record, lockup_until: 101.years.from_now) }
    let!(:account_token_record_min_lockup) { create(:account_token_record, lockup_until: AccountTokenRecord::LOCKUP_UNTIL_MIN) }
    let!(:account_token_record) { create(:account_token_record) }

    it 'returns "> 100 years" if value is more than 100 years from now' do
      expect(account_token_record_max_lockup.decorate.lockup_until_pretty).to eq('> 100 years')
    end

    it 'returns "none" if value is min' do
      expect(account_token_record_min_lockup.decorate.lockup_until_pretty).to eq('None')
    end

    it 'returns formatted date' do
      expect(account_token_record.decorate.lockup_until_pretty).to eq(account_token_record.lockup_until.strftime('%b %e, %Y'))
    end
  end
end
