describe Revenue do
  specify do
    validation_errors = Revenue.new.tap(&:valid?).errors.full_messages.sort
    expect(validation_errors.sort).to match ["Amount can't be blank",
                                             "Amount is not a number",
                                             "Currency can't be blank",
                                             "Project can't be blank",
                                            ].sort
  end

  specify do
    revenue = Revenue.new
    revenue.amount = -1
    expect(revenue.valid?).to eq(false)
    expect(revenue.errors[:amount]).to eq(["must be greater than 0"])
  end
end