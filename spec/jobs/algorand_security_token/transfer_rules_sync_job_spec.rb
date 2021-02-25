require 'rails_helper'

RSpec.describe AlgorandSecurityToken::TransferRulesSyncJob, type: :job, vcr: true do
  let(:token) { create(:algo_sec_token, contract_address: '13997710') }
  subject { described_class.perform_now(token) }

  it 'creates transfer rules' do
    expect { subject }.to change(token.transfer_rules, :count).by(3)

    expect(token.transfer_rules.synced.where(
             lockup_until: 1,
             sending_group: RegGroup.find_by(token: token, blockchain_id: 1),
             receiving_group: RegGroup.find_by(token: token, blockchain_id: 1)
           )).not_to be_empty

    expect(token.transfer_rules.synced.where(
             lockup_until: 2021,
             sending_group: RegGroup.find_by(token: token, blockchain_id: 2),
             receiving_group: RegGroup.find_by(token: token, blockchain_id: 2)
           )).not_to be_empty

    expect(token.transfer_rules.synced.where(
             lockup_until: 1614129708,
             sending_group: RegGroup.find_by(token: token, blockchain_id: 2),
             receiving_group: RegGroup.find_by(token: token, blockchain_id: 1)
           )).not_to be_empty
  end
end
