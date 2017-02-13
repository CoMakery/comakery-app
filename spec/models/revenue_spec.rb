require 'rails_helper'

describe Revenue do
  describe 'validations' do
    specify do
      validation_errors = Revenue.new.tap(&:valid?).errors.full_messages.sort
      expect(validation_errors.sort).to match ["Amount can't be blank",
                                               "Amount is not a number",
                                               "Currency can't be blank",
                                               "Project can't be blank",
                                               "Currency is not included in the list"
                                              ].sort
    end

    it 'has an amount greater than 0' do
      revenue = Revenue.new
      revenue.amount = -1
      expect(revenue.valid?).to eq(false)
      expect(revenue.errors[:amount]).to eq(["must be greater than 0"])
    end

    describe '#currency' do
      let(:revenue) { build :revenue }

      Comakery::Currency::DENOMINATIONS.each do |string, symbol|
        it "should allow #{string}" do
          revenue.currency = string
          expect(revenue).to be_valid
        end
      end

      it 'should not allow non-currency strings' do
        revenue.currency = "magenta"
        expect(revenue).to_not be_valid
      end
    end
  end

  describe ".total_revenue" do
    describe 'with no revenue' do
      specify { expect(Revenue.total_amount).to eq(0) }
    end

    describe 'with project revenue' do
      let!(:project1) { create :project }
      let!(:project2) { create :project }

      before do
        project1.revenues.create(amount: 3, currency: 'USD')
        project1.revenues.create(amount: 5, currency: 'USD')

        project2.revenues.create(amount: 7, currency: 'USD')
        project2.revenues.create(amount: 11, currency: 'USD')
      end

      specify do
        expect(Revenue.total_amount).to eq(26)
      end

      it 'can be scoped to a project' do
        expect(project1.revenues.total_amount).to eq(8)
        expect(project2.revenues.total_amount).to eq(18)
      end
    end
  end

  describe 'amount saving' do
    let(:revenue) { build :revenue }

    it 'should strip commas but retain decimals' do
      revenue.amount = '1,234.56'
      revenue.save!
      expect(revenue.amount).to eq(1_234.56)
    end
  end
end