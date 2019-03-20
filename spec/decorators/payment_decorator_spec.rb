require 'rails_helper'

describe PaymentDecorator do
  let(:project) { create :project, payment_type: 'revenue_share' }
  let(:award_type) { create :award_type, project: project }
  let(:account) { create :account, first_name: 'Diana', last_name: 'Ross' }
  let(:issuer) { create :account, first_name: 'Michael', last_name: 'Jackson' }
  let(:payment) { Payment.new(account: account, project: project, total_value: 100, share_value: 50, currency: 'USD', issuer: issuer) }

  describe 'display' do
    it 'total_value_pretty' do
      expect(payment.decorate.total_value_pretty).to eq '$100.00'
    end

    it 'share_value_pretty' do
      expect(payment.decorate.share_value_pretty).to eq '$50.00000000'
    end

    it 'total_payment_pretty' do
      expect(payment.decorate.total_payment_pretty).to be_nil
      payment.total_payment = 100
      expect(payment.decorate.total_payment_pretty).to eq '$100.00'
    end

    it 'transaction_fee_pretty' do
      expect(payment.decorate.transaction_fee_pretty).to be_nil
      payment.transaction_fee = 10
      expect(payment.decorate.transaction_fee_pretty).to eq '$10.00'
    end

    it 'currency_symbol' do
      expect(payment.decorate.currency_symbol).to eq '$'
    end

    it 'payee_name' do
      expect(payment.decorate.payee_name).to eq 'Diana Ross'
    end

    it 'status' do
      expect(payment.decorate.status).to eq 'Unpaid'
    end

    it 'payee_avatar' do
      expect(payment.decorate.payee_avatar).to eq account.image
    end

    it 'issuer_name' do
      expect(payment.decorate.issuer_name).to eq 'Michael Jackson'
    end

    it 'issuer_avatar' do
      expect(payment.decorate.issuer_avatar).to eq issuer.image
    end
  end
end
