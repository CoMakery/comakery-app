require 'rails_helper'

describe Award do
  describe 'associations' do
    it 'has the expected associations' do
      described_class.create!(
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

  describe '#issuer_display_name' do
    let!(:issuer) { create :account, first_name: 'johnny' }
    let!(:project) { create :project, account: issuer }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, award_type: award_type, issuer: issuer }

    it 'returns the user name' do
      expect(award.issuer_display_name).to eq('johnny')
    end
  end

  context 'recipient names' do
    let!(:recipient) { create(:account, first_name: 'Betty', last_name: 'Ross') }
    let!(:project) { create :project }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, account: recipient, award_type: award_type }

    describe '#recipient_display_name' do
      it 'returns the full name' do
        expect(award.recipient_display_name).to eq('Betty Ross')
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
end
