require 'rails_helper'

RSpec.describe BlockchainJob::ComakerySecurityTokenJob::TransferRulesSyncJob, type: :job do
  let(:token) do
    create(
      :token,
      _token_type: :comakery_security_token,
      symbol: 'TEST',
      decimal_places: 0,
      contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
      _blockchain: 'ethereum_ropsten',
      ethereum_network: 'ropsten'
    )
  end

  example 'create reg groups and transfer rules' do
    expect(token.reg_groups.count).to eq 1
    expect(token.transfer_rules.count).to be_zero

    VCR.use_cassette("infura/#{token._blockchain}/#{token.contract_address}/filtered_logs") do
      described_class.perform_now(token)
    end

    token.reload
    expect(token.reg_groups.count).to eq 10
    expect(token.transfer_rules.count).to eq 35

    transfer_rule = token.transfer_rules.first
    expect(transfer_rule.token_id).to eq token.id
    expect(transfer_rule.sending_group).to be_truthy
    expect(transfer_rule.receiving_group).to be_truthy
    expect(transfer_rule.lockup_until).to be > Time.zone.at(0)
    expect(transfer_rule.synced_at).to be > 5.seconds.ago
    expect(transfer_rule.status).to eq 'synced'

    reg_group = token.reg_groups.order(blockchain_id: :desc).first
    expect(reg_group.token_id).to eq token.id
    expect(reg_group.name).to eq '10'
    expect(reg_group.blockchain_id).to eq 10

    permanently_locked_transfer_rules = token.transfer_rules.where('lockup_until = 0 or lockup_until is null')
    expect(permanently_locked_transfer_rules.count).to be_zero
  end

  example 'do not overwrite existing rules and reg groups' do
    reg_group = RegGroup.create!(name: 'Named group', blockchain_id: 1, token: token)
    transfer_rule = TransferRule.create!(token: token, sending_group: reg_group, receiving_group: reg_group, lockup_until: Time.current, status: 'synced')

    VCR.use_cassette("infura/#{token._blockchain}/#{token.contract_address}/filtered_logs") do
      described_class.perform_now(token)
    end

    token.reload
    expect(token.reg_groups.count).to eq 10
    expect(token.transfer_rules.count).to eq 35

    reg_group.reload
    expect(reg_group.token_id).to eq token.id
    expect(reg_group.name).to eq 'Named group'
    expect(reg_group.blockchain_id).to eq 1

    expect(TransferRule.find_by(id: transfer_rule.id)).to be_nil # old rule was deleted

    new_transfer_rule = TransferRule.find_by!(token: token, sending_group: reg_group, receiving_group: reg_group, status: 'synced')
    expect(new_transfer_rule.lockup_until).to eq Time.zone.parse('2020-04-07')
    expect(new_transfer_rule.synced_at).to be > 5.seconds.ago
  end

  example 'with empty filter' do
    allow_any_instance_of(described_class).to receive(:filtered_events).and_return([])

    described_class.perform_now(token)

    token.reload
    expect(token.reg_groups.count).to eq 1
    expect(token.transfer_rules.count).to be_zero
  end
end
