require "rails_helper"

describe Payment do
  specify do
    validation_errors = Payment.new.tap(&:valid?).errors.full_messages
    expect(validation_errors.sort).to eq([
                                        "Quantity redeemed can't be blank",
                                        "Share value can't be blank",
                                        "Total value can't be blank",
                                        "Project can't be blank",
                                        "Payee can't be blank",
                                        "Quantity redeemed is not a number",
                                        "Total value is not a number"
                                    ].sort)
  end

  it 'reconciled false by default' do
    expect(Payment.new.reconciled).to eq(false)
  end

  describe 'validations' do
    let(:project) { create :project }
    let(:award_type) { create :award_type, amount: 1, project: project}
    let(:payee_auth) { create :authentication }
    let(:payment) { Payment.new(payee: payee_auth, project: project, total_value: 0, share_value: 0) }

    it 'Cannot redeem less than 0 shares' do
      payment.quantity_redeemed = -1
      expect(payment).to_not be_valid
      expect(payment.errors[:quantity_redeemed]).to eq(["must be greater than or equal to 0"])
    end

    it 'Total value cannot be less than 0' do
      payment.total_value = -1
      expect(payment).to_not be_valid
      expect(payment.errors[:total_value]).to eq(["must be greater than or equal to 0"])
    end

    it 'Cannot redeem more shares than they have' do
      payment.quantity_redeemed = 1
      expect(payment).to_not be_valid
      expect(payment.errors[:quantity_redeemed]).to eq(["cannot be greater than the payee's total awards remaining balance"])
    end

    it 'Payee can redeem shares that they do have' do
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: payee_auth )
      expect(payee_auth.total_awards_remaining(project)).to eq(1)
      payment.quantity_redeemed = 1
      payment.valid?
      expect(payment.errors[:quantity_redeemed]).to eq([])
    end

    it "can't update the quantity_redeemed to an amount greater than they have" do
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: payee_auth )
      expect(payee_auth.total_awards_remaining(project)).to eq(1)
      payment.quantity_redeemed = 1
      payment.save!
      payment.quantity_redeemed = 2
      expect(payment).to_not be_valid
      expect(payment.errors[:quantity_redeemed]).to eq(["cannot be greater than the payee's total awards remaining balance"])
    end

    it "can update the quantity_redeemed to an amount they have" do
      award_type.awards.create_with_quantity(2, issuer: project.owner_account, authentication: payee_auth )
      expect(payee_auth.total_awards_remaining(project)).to eq(2)
      payment.quantity_redeemed = 1
      payment.save!
      payment.quantity_redeemed = 2
      expect(payment).to be_valid
    end

    it "can update the quantity_redeemed to an amount they have that is lower than the previous amount" do
      award_type.awards.create_with_quantity(2, issuer: project.owner_account, authentication: payee_auth )
      expect(payee_auth.total_awards_remaining(project)).to eq(2)
      payment.quantity_redeemed = 2
      payment.save!
      payment.quantity_redeemed = 1
      expect(payment).to be_valid
    end
  end
end
