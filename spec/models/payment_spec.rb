require "rails_helper"

describe Payment do
  specify do
    validation_errors = Payment.new.tap(&:valid?).errors.full_messages
    expect(validation_errors.sort).to eq([
                                             "Currency can't be blank",
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
    let(:award_type) { create :award_type, amount: 1, project: project }
    let(:payee_auth) { create :authentication }
    let(:payment) { Payment.new(payee: payee_auth, project: project, total_value: 0, share_value: 0, currency: 'USD') }

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
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: payee_auth)
      expect(payee_auth.total_awards_remaining(project)).to eq(1)
      payment.quantity_redeemed = 1
      payment.valid?
      expect(payment.errors[:quantity_redeemed]).to eq([])
    end

    it "can't update the quantity_redeemed to an amount greater than they have" do
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: payee_auth)
      expect(payee_auth.total_awards_remaining(project)).to eq(1)
      payment.quantity_redeemed = 1
      payment.save!
      payment.quantity_redeemed = 2
      expect(payment).to_not be_valid
      expect(payment.errors[:quantity_redeemed]).to eq(["cannot be greater than the payee's total awards remaining balance"])
    end

    it "can update the quantity_redeemed to an amount they have" do
      award_type.awards.create_with_quantity(2, issuer: project.owner_account, authentication: payee_auth)
      expect(payee_auth.total_awards_remaining(project)).to eq(2)
      payment.quantity_redeemed = 1
      payment.save!
      payment.quantity_redeemed = 2
      expect(payment).to be_valid
    end

    it "can update the quantity_redeemed to an amount they have that is lower than the previous amount" do
      award_type.awards.create_with_quantity(2, issuer: project.owner_account, authentication: payee_auth)
      expect(payee_auth.total_awards_remaining(project)).to eq(2)
      payment.quantity_redeemed = 2
      payment.save!
      payment.quantity_redeemed = 1
      expect(payment).to be_valid
    end

    describe 'must have correct precision total_payment for the currency' do
      specify do
        payment.total_payment = 10.001
        payment.currency= 'USD'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_payment]).to eq(["must use only 2 decimal places for USD"])
      end

      specify do
        payment.total_payment = 10.123456789
        payment.currency= 'BTC'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_payment]).to eq(["must use only 8 decimal places for BTC"])
      end

      it 'let currency requirement handle blank currency' do
        payment.total_payment = 10.123456789
        payment.currency= nil
        expect(payment).to_not be_valid
        expect(payment.errors[:total_payment]).to eq([])
        expect(payment.errors[:currency]).to eq(["can't be blank"])
      end
    end

    describe 'must have correct precision total_value for the currency' do
      specify do
        payment.total_value = 10.001
        payment.currency= 'USD'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["must use only 2 decimal places for USD"])
      end

      specify do
        payment.total_value = 10.123456789
        payment.currency= 'BTC'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["must use only 8 decimal places for BTC"])
      end

      it 'let currency requirement handle blank currency' do
        payment.total_value = 10.123456789
        payment.currency= nil
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq([])
        expect(payment.errors[:currency]).to eq(["can't be blank"])
      end
    end

    describe "with quantity_redeemed, share_value, total_value, fee, and payment amount" do
      let!(:project) { create :project }
      let!(:award_type) { create :award_type, amount: 1, project: project }
      let!(:payee_auth) { create :authentication }
      let!(:payment) { Payment.new(payee: payee_auth,
                                   project: project,
                                   total_value: 1,
                                   share_value: 1,
                                   quantity_redeemed: 1,
                                   transaction_fee: 0.1,
                                   total_payment: 0.9,
                                   currency: 'USD') }
      let!(:award) { award_type.awards.create_with_quantity(100,
                                                            issuer: project.owner_account,
                                                            authentication: payee_auth) }

      it 'is valid when they add up' do
        expect(payment).to be_valid
      end

      specify do
        payment.total_value = 2
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["2.0 does not match the quantity 1 and share value 1.0"])
      end

      specify do
        payment.quantity_redeemed = 17
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["1.0 does not match the quantity 17 and share value 1.0"])
      end

      specify do
        payment.transaction_fee = 0.13
        payment.total_payment = 1337
        expect(payment).to_not be_valid
        expect(payment.errors[:total_payment]).to eq(["is not equal to the total value minus the transaction fee"])
      end
    end

    describe "has min total_value specific to the currency" do
      let!(:project) { create :project }
      let!(:award_type) { create :award_type, amount: 1, project: project }
      let!(:payee_auth) { create :authentication }
      let!(:payment) { Payment.new(payee: payee_auth,
                                   project: project,
                                   total_value: 1,
                                   share_value: 1,
                                   quantity_redeemed: 1,
                                   transaction_fee: 0.1,
                                   total_payment: 0.9,
                                   currency: 'USD') }
      let!(:award) { award_type.awards.create_with_quantity(100,
                                                            issuer: project.owner_account,
                                                            authentication: payee_auth) }

      before do
        payment.quantity_redeemed = 1
        payment.total_payment = nil
      end

      specify do
        payment.total_value = 9
        payment.share_value = 9
        payment.currency= 'USD'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["must be greater than or equal to $10"])
      end

      specify do
        payment.total_value = 0.0009
        payment.share_value = 0.0009
        payment.currency= 'BTC'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["must be greater than or equal to ฿0.001"])
      end

      specify do
        payment.total_value = 0.0009
        payment.share_value = 0.0009
        payment.currency= 'ETH'
        expect(payment).to_not be_valid
        expect(payment.errors[:total_value]).to eq(["must be greater than or equal to Ξ0.1"])
      end
    end
  end

  describe "#truncate_total_value_to_currency" do
    let(:project) { create :project }
    let(:award_type) { create :award_type, amount: 1, project: project }
    let(:payee_auth) { create :authentication }
    let(:payment) { Payment.new(payee: payee_auth, project: project, total_value: 0, share_value: 0, currency: 'USD') }

    specify do
      payment.currency = 'USD'
      payment.total_value = 0.999
      payment.truncate_total_value_to_currency_precision
      expect(payment.total_value).to eq(0.99)
    end

    specify do
      payment.currency = 'BTC'
      payment.total_value = 0.123456789
      payment.truncate_total_value_to_currency_precision
      expect(payment.total_value).to eq(0.12345678)
    end

    specify do
      payment.total_value = nil
      payment.truncate_total_value_to_currency_precision
      expect(payment.total_value).to eq(nil)
    end
  end

  describe 'scopes' do
    let!(:project) { create :project, royalty_percentage: 100 }
    let!(:award_type) { create :award_type, amount: 1, project: project }
    let!(:payee_auth) { create :authentication }
    let!(:award1) { award_type.awards.create_with_quantity(100,
                                                           issuer: project.owner_account,
                                                           authentication: payee_auth) }
    let!(:revenues) { project.revenues.create!(amount: 50, currency: 'USD', recorded_by: project.owner_account) }

    let!(:payment1) { project.payments.create_with_quantity(payee_auth: payee_auth, quantity_redeemed: 1) }
    let!(:payment2) { project.payments.create_with_quantity(payee_auth: payee_auth, quantity_redeemed: 6) }

    specify do
      expect(Payment.total_awards_redeemed).to eq(7)
    end

    specify do
      expect(Payment.total_value_redeemed).to eq(3.5)
    end
  end
end
