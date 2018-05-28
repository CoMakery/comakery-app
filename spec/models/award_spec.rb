require 'rails_helper'

describe Award do
  describe 'associations' do
    it 'has the expected associations' do
      described_class.create!(
        issuer: create(:account),
        account: create(:account),
        award_type: create(:award_type),
        proof_id: 'xyz123',
        total_amount: 100,
        unit_amount: 50,
        quantity: 2
      )
    end
  end

  describe 'validations' do
    it 'requires things be present' do
      expect(described_class.new(quantity: nil).tap(&:valid?).errors.full_messages)
        .to match_array([
                          "Award type can't be blank",
                          "Quantity can't be blank",
                          "Unit amount can't be blank",
                          "Total amount can't be blank",
                          'Unit amount is not a number',
                          'Quantity is not a number',
                          'Total amount is not a number'
                        ])
    end
    describe 'awards amounts must be > 0' do
      let(:award) { build :award }

      specify do
        award.quantity = -1
        expect(award.valid?).to eq(false)
        expect(award.errors[:quantity]).to eq(['must be greater than 0'])
      end

      specify do
        award.total_amount = -1
        expect(award.valid?).to eq(false)
        expect(award.errors[:total_amount]).to eq(['must be greater than 0'])
      end

      specify do
        award.unit_amount = -1
        expect(award.valid?).to eq(false)
        expect(award.errors[:unit_amount]).to eq(['must be greater than 0'])
      end
    end

    describe '#ethereum_transaction_address' do
      let(:award) { create(:award) }
      let(:address) { '0x' + 'a' * 64 }

      it 'validates with a valid ethereum transaction address' do
        expect(build(:award, ethereum_transaction_address: nil)).to be_valid
        expect(build(:award, ethereum_transaction_address: "0x#{'a' * 64}")).to be_valid
        expect(build(:award, ethereum_transaction_address: "0x#{'A' * 64}")).to be_valid
      end

      it 'does not validate with an invalid ethereum transaction address' do
        expected_error_message = "Ethereum transaction address should start with '0x', followed by a 64 character ethereum address"
        expect(build(:award, ethereum_transaction_address: 'foo').tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: '0x').tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x#{'a' * 63}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x#{'a' * 65}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:award, ethereum_transaction_address: "0x#{'g' * 64}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end

      it { expect(award.ethereum_transaction_address).to eq(nil) }

      it 'can be set' do
        award.ethereum_transaction_address = address
        award.save!
        award.reload
        expect(award.ethereum_transaction_address).to eq(address)
      end

      it 'once set cannot be set unset' do
        award.ethereum_transaction_address = address
        award.save!
        award.ethereum_transaction_address = nil
        expect(award).not_to be_valid
        expect(award.errors.full_messages.to_sentence).to match \
          /Ethereum transaction address cannot be changed after it has been set/
      end

      it 'once set it cannot be set to another value' do
        award.ethereum_transaction_address = address
        award.save!
        award.ethereum_transaction_address = '0x' + 'b' * 64
        expect(award).not_to be_valid
        expect(award.errors.full_messages.to_sentence).to match \
          /Ethereum transaction address cannot be changed after it has been set/
      end
    end
  end

  describe '#total_amount should round' do
    specify do
      award = create :award, quantity: 1.4, unit_amount: 1, total_amount: 1.4
      award.reload
      expect(award.total_amount).to eq(1)
    end

    specify do
      award = create :award, quantity: 1.5, unit_amount: 1, total_amount: 1.5
      award.reload
      expect(award.total_amount).to eq(2)
    end
  end

  describe '.total_awarded' do
    describe 'without project awards' do
      specify { expect(described_class.total_awarded).to eq(0) }
    end

    describe 'with project awards' do
      let!(:project1) { create :project }
      let!(:project1_award_type) { (create :award_type, project: project1, amount: 3) }
      let(:project2) { create :project }
      let!(:project2_award_type) { (create :award_type, project: project2, amount: 5) }
      let(:account) { create :account }

      before do
        project1_award_type.awards.create_with_quantity(5, issuer: project1.account, account: account)
        project1_award_type.awards.create_with_quantity(5, issuer: project1.account, account: account)

        project2_award_type.awards.create_with_quantity(3, issuer: project2.account, account: account)
        project2_award_type.awards.create_with_quantity(7, issuer: project2.account, account: account)
      end

      it 'is able to scope to a project' do
        expect(project1.awards.total_awarded).to eq(30)
        expect(project2.awards.total_awarded).to eq(50)
      end

      it 'returns the total amount of awards issued' do
        expect(described_class.total_awarded).to eq(80)
      end
    end
  end

  describe 'helper methods' do
    let!(:team) { create :team }
    let!(:team1) { create :team, provider: 'discord' }
    let!(:account) { create :account, email: 'reciver@test.st' }
    let!(:authentication) { create :authentication, account: account }
    let!(:account1) { create :account }
    let!(:authentication1) { create :authentication, account: account1, provider: 'discord' }
    let!(:project) { create :project, account: account }
    let!(:award_type) { (create :award_type, project: project, amount: 3) }
    let!(:award) { create :award, award_type: award_type, issuer: account, account: account }
    let!(:award1) { create :award, award_type: award_type, issuer: account, account: account1 }

    before do
      team.build_authentication_team authentication
      team1.build_authentication_team authentication1
      stub_discord_channels
      project.channels.create(team: team1, channel_id: 'general')
    end

    it 'check for ethereum issue ready' do
      expect(award.ethereum_issue_ready?).to be_falsey

      project.update ethereum_enabled: true
      account.update ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423'

      expect(award.reload.ethereum_issue_ready?).to be_truthy
    end
    it 'check self_issued award' do
      expect(award.self_issued?).to be_truthy
      expect(award1.self_issued?).to be_falsey
    end

    it 'check discord award' do
      expect(award.discord?).to be_falsey
      expect(award1.discord?).to be_falsey
      award1.update channel_id: project.channels.last.id
      expect(award1.reload.discord?).to be_truthy
    end

    it 'round total_amount' do
      award.total_amount = 2.2
      award.save
      expect(award.reload.total_amount).to eq 2
    end

    it 'return recipient_auth_team' do
      auth_team = account1.authentication_teams.last
      award1.channel = project.channels.last
      award1.save
      expect(award.recipient_auth_team).to be_nil
      expect(award1.recipient_auth_team).to eq auth_team
    end

    it 'send send_confirm_email' do
      award.update email: 'reciver@test.st'
      expect { award.send_confirm_email }.to change { ActionMailer::Base.deliveries.count }.by(0)
      award.update confirm_token: '1234'
      expect { award.send_confirm_email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'confirm award' do
      award.update email: 'reciver@test.st', confirm_token: '1234'
      award.confirm!(account1)
      award.reload
      expect(award.account).to eq account1
      expect(award.confirmed?).to eq true
    end
  end

  describe '#send_award_notifications' do
    let!(:team) { create :team }
    let!(:account) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:discord_team) { create :team, provider: 'discord' }
    let!(:project) { create :project, account: account }
    let!(:award_type) { create :award_type, project: project }
    let!(:channel) { create :channel, team: team, project: project }
    let!(:award) { create :award, award_type: award_type, issuer: account, channel: channel }

    before do
      team.build_authentication_team authentication
    end

    it 'sends a Slack notification' do
      allow(award).to receive(:send_award_notifications)
      award.send_award_notifications
      expect(award).to have_received(:send_award_notifications)
    end

    it 'sends a Discord notification' do
      stub_discord_channels
      channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'discord_channel')
      award = create :award, award_type: award_type, issuer: account, channel: channel
      allow(award.discord_client).to receive(:send_message)
      award.send_award_notifications
      expect(award.discord_client).to have_received(:send_message)
    end
  end
end
