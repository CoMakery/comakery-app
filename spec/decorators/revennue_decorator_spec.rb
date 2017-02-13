require 'rails_helper'

describe RevenueDecorator do
  let(:amount_with_24_decimal_precision) { BigDecimal('9.999_999_999_999_999_999_999') }
  let(:revenue) { (create :revenue, amount: amount_with_24_decimal_precision).reload.decorate }

  describe 'initialization conditions' do
    specify { expect(revenue.amount).to eq(amount_with_24_decimal_precision) }
  end

  describe 'truncates instead of rounds' do
    specify do
      revenue.currency = 'USD'
      expect(revenue.amount_pretty).to eq("$9.99")
    end

    specify do
      revenue.currency = 'BTC'
      expect(revenue.amount_pretty).to eq("฿9.99999999")
    end

    specify do
      revenue.currency = 'ETH'
      expect(revenue.amount_pretty).to eq("Ξ9.999999999999999999")
    end
  end
end