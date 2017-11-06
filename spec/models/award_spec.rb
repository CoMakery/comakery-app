require 'rails_helper'

describe Award do
  describe 'associations' do
    it 'has the expected associations' do
      described_class.create!(
        authentication: create(:authentication),
        issuer: create(:account),
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
                          "Authentication can't be blank",
                          "Award type can't be blank",
                          "Issuer can't be blank",
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

  describe '#issuer_display_name' do
    let!(:issuer) { create :account }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, issuer: issuer, award_type: award_type }

    it 'returns the user name' do
      create(:authentication, account: issuer, slack_team_id: 'reds', slack_user_name: 'johnny', slack_first_name: nil, slack_last_name: nil)
      expect(award.issuer_display_name).to eq('@johnny')
    end

    it 'returns the auth for the correct team, even if older' do
      travel_to Date.new(2015)
      create(:authentication, account: issuer, slack_team_id: 'reds', slack_user_name: 'johnny-red', slack_first_name: nil, slack_last_name: nil)
      travel_to Date.new(2016)
      create(:authentication, account: issuer, slack_team_id: 'blues', slack_user_name: 'johnny-blue', slack_first_name: nil, slack_last_name: nil)
      expect(award.issuer_display_name).to eq('@johnny-red')
    end

    it "doesn't explode if auth is missing" do
      expect(award.issuer_display_name).to be_nil
    end
  end

  context 'recipient names' do
    let!(:recipient) { create(:authentication, slack_team_id: 'reds', slack_first_name: 'Betty', slack_last_name: 'Ross', slack_user_name: 'betty') }
    let!(:project) { create :project, slack_team_id: 'reds' }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, authentication: recipient, award_type: award_type }

    describe '#recipient_display_name' do
      it 'returns the full name' do
        expect(award.recipient_display_name).to eq('Betty Ross')
      end
    end

    describe '#recipient_slack_user_name' do
      it 'returns the user name' do
        expect(award.recipient_slack_user_name).to eq('betty')
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
      let(:issuer) { create :account }
      let(:authentication) { create :authentication }

      before do
        project1_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
        project1_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)

        project2_award_type.awards.create_with_quantity(3, issuer: issuer, authentication: authentication)
        project2_award_type.awards.create_with_quantity(7, issuer: issuer, authentication: authentication)
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
end
