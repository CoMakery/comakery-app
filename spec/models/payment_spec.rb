require 'spec_helper'

describe Payment do
  specify do
    validation_errors = Payment.new.tap(&:valid?).errors.full_messages.sort
    expect(validation_errors).to eq([
                                        "Amount can't be blank",
                                        "Issuer can't be blank",
                                        "Project can't be blank",
                                        "Recipient can't be blank",
                                    ])
  end
end
