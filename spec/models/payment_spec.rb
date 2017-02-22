require 'spec_helper'

describe Payment do
  specify do
    validation_errors = Payment.new.tap(&:valid?).errors.full_messages
    expect(validation_errors.sort).to eq([
                                        "Quantity redeemed can't be blank",
                                        "Share value can't be blank",
                                        "Total value can't be blank",
                                        "Project can't be blank",
                                        "Payee can't be blank"
                                    ].sort)
  end
end
