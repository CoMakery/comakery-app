require 'rails_helper'

describe AwardType do
  describe "#validations" do
    it "requires many attributes" do
      award_type = AwardType.new
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to eq(["Project can't be blank", "Name can't be blank", "Amount can't be blank"])
    end

    it "prevents modification of amount if there are existing awards" do
      award_type = create(:award).award_type
      award_type.amount += 1000
      expect(award_type).not_to be_valid
      expect(award_type.errors.full_messages).to be_include("Amount can't be modified if there are existing awards")
    end
  end

  describe "associations" do
    let(:project) { create(:project, owner_account: create(:account)) }
    let(:award_type) { create(:award_type, project: project) }
    let(:award) { create(:award, award_type: award_type) }

    it "belongs to a project" do
      expect(award_type.project).to eq(project)
    end

    it "has many awards" do
      expect(award_type.awards).to match_array([award])
    end
  end

  describe "scopes" do
    describe "#modifiable?" do
      it "returns true if there are awards" do
        award_type = create(:award_type)
        expect(award_type).to be_modifiable

        create(:award, award_type: award_type)
        expect(award_type).not_to be_modifiable
      end
    end
  end

  describe '#write_award_amount' do
    let!(:award_type_a) { create :award_type, amount: 16 }
    let!(:award1_type_a) { create :award, award_type: award_type_a, quantity: 1 }
    let!(:award2_type_a) { create :award, award_type: award_type_a, quantity: 2 }
    let!(:award3_type_b) { create :award, quantity: 5, unit_amount: 10, total_amount: 50 }

    before do
      award1_type_a.update(unit_amount: 7, total_amount: 7)
      award2_type_a.update(unit_amount: 7, total_amount: 14)
      award_type_a.write_award_amount

      award1_type_a.reload
      award2_type_a.reload
      award3_type_b.reload
    end

    specify { expect(award1_type_a.unit_amount).to eq 16 }
    specify { expect(award1_type_a.total_amount).to eq 16 }

    specify { expect(award2_type_a.unit_amount).to eq 16 }
    specify { expect(award2_type_a.total_amount).to eq 32 }

    specify { expect(award3_type_b.unit_amount).to eq 10 }
    specify { expect(award3_type_b.total_amount).to eq 50 }
  end

  describe '.write_all_award_amounts' do
    let!(:award_type_a) { create :award_type, amount: 16 }
    let!(:award_type_b) { create :award_type, amount: 17 }
    let!(:award1_type_a) { create :award, award_type: award_type_a, quantity: 1 }
    let!(:award2_type_b) { create :award, award_type: award_type_b, quantity: 1 }

    before do
      award1_type_a.update(unit_amount: 7, total_amount: 7)
      award2_type_b.update(unit_amount: 7, total_amount: 14)

      AwardType.write_all_award_amounts

      award1_type_a.reload
      award2_type_b.reload
    end

    specify { expect(award1_type_a.unit_amount).to eq(16) }
    specify { expect(award1_type_a.total_amount).to eq(16) }

    specify { expect(award2_type_b.unit_amount).to eq(17) }
    specify { expect(award2_type_b.total_amount).to eq(17) }
  end

  describe "#awards#create_with_quantity" do
    let(:award_type) { create :award_type, amount: 1 }
    let(:issuer) { create :account }
    let(:authentication) { create :authentication}
    let(:award) { award_type.awards.create_with_quantity 1.4,
                                                         issuer: issuer,
                                                         authentication: authentication }

    specify { expect(award.quantity).to eq(1.4) }

    specify { expect(award.unit_amount).to eq(1) }

    specify { expect(award.total_amount).to eq(1) }

    specify { expect(award).to be_persisted }

    it 'rounds up when >= x.5' do
      roundup_award = award_type.awards.create_with_quantity(1.5,
                                                             issuer: issuer,
                                                             authentication: authentication)
      expect(roundup_award.total_amount).to eq(2)
    end
  end
end
