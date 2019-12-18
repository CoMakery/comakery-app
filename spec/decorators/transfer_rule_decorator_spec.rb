require 'rails_helper'

RSpec.describe TransferRuleDecorator do
  describe 'eth_data' do
    let!(:transfer_rule) { create(:transfer_rule) }

    it 'returns data for transfer-rule-form_controller.js' do
      data = transfer_rule.decorate.eth_data

      expect(data['transfer-rule-form-rule-from-group-id']).to eq(transfer_rule.sending_group.blockchain_id)
      expect(data['transfer-rule-form-rule-to-group-id']).to eq(transfer_rule.receiving_group.blockchain_id)
      expect(data['transfer-rule-form-rule-lockup-until']).to eq(transfer_rule.lockup_until.strftime('%b %e, %Y'))
    end
  end
end
