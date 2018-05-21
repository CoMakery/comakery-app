require 'rails_helper'

describe AccountDecorator do
  subject(:account) { create :account, password: '12345678' }

  before do
    stub_discord_channels
  end

  describe '#name' do
    it 'returns the first and last name and falls back to the user name' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson').decorate.name).to eq('Bob Johnson')
      expect(build(:account, first_name: nil, last_name: 'Johnson').decorate.name).to eq('Johnson')
      expect(build(:account, first_name: 'Bob', last_name: '').decorate.name).to eq('Bob')
    end
  end

  describe '#nick' do
    it 'returns the nickname and falls back to the name' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson').decorate.nick).to eq('Bob Johnson')
      expect(build(:account, first_name: nil, last_name: 'Johnson').decorate.nick).to eq('Johnson')
      expect(build(:account, first_name: 'Bob', last_name: '').decorate.nick).to eq('Bob')
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson', nickname: 'bobjon').decorate.nick).to eq('bobjon')
    end
  end

  describe '#total_awards_earned_pretty' do
    let!(:contributor) { create(:account) }
    let!(:bystander) { create(:account) }
    let!(:project) { create :project, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:award1) { create :award, account: contributor, issuer: project.account, award_type: award_type }
    let!(:award2) { create :award, account: contributor, issuer: project.account, award_type: award_type, quantity: 3.5 }

    specify do
      expect(bystander.decorate.total_awards_earned_pretty(project)).to eq '0'
    end

    specify do
      expect(contributor.decorate.total_awards_earned_pretty(project)).to eq '45'
    end
  end

  describe '#total_awards_remaining_pretty' do
    let!(:contributor) { create(:account) }
    let!(:bystander) { create(:account) }
    let!(:project) { create :project, payment_type: 'revenue_share'  }
    let!(:revenue) { create :revenue, amount: 1000, project: project }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:award1) { create :award, account: contributor, issuer: project.account, award_type: award_type }
    let!(:award2) { create :award, account: contributor, issuer: project.account, award_type: award_type }
    let!(:payment1) { project.payments.create_with_quantity(quantity_redeemed: 10, account: contributor) }
    let!(:payment2) { project.payments.create_with_quantity(quantity_redeemed: 1, account: contributor) }

    specify do
      expect(bystander.decorate.total_awards_remaining_pretty(project)).to eq '0'
    end

    specify do
      expect(contributor.decorate.total_awards_remaining_pretty(project)).to eq '9'
    end
  end

  describe '#total_revenue_paid_pretty' do
    let!(:contributor) { create(:account) }
    let!(:bystander) { create(:account) }
    let!(:project) { create :project, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:revenue) { create :revenue, amount: 1000, project: project }

    before do
      award_type.awards.create_with_quantity(2, account: contributor, issuer: project.account)
      project.payments.create_with_quantity(quantity_redeemed: 10, account: contributor)
      project.payments.create_with_quantity(quantity_redeemed: 1, account: contributor)
    end

    specify do
      expect(bystander.decorate.total_revenue_paid_pretty(project)).to eq '$0.00'
    end

    specify do
      expect(contributor.decorate.total_revenue_paid_pretty(project)).to eq '$32.45'
    end
  end

  describe '#percentage_of_unpaid_pretty' do
    let!(:contributor) { create(:account) }
    let!(:bystander) { create(:account) }
    let!(:project) { create :project, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:revenue) { create :revenue, amount: 1000, project: project }

    before do
      award_type.awards.create_with_quantity(2, account: contributor, issuer: project.account)
      project.payments.create_with_quantity(quantity_redeemed: 10, account: contributor)
      project.payments.create_with_quantity(quantity_redeemed: 1, account: contributor)
    end

    specify do
      expect(bystander.decorate.percentage_of_unpaid_pretty(project)).to eq '0.0%'
    end

    specify do
      expect(contributor.decorate.percentage_of_unpaid_pretty(project)).to eq '100.0%'
    end
  end

  describe 'revenue' do
    let!(:contributor) { create(:account) }
    let!(:bystander) { create(:account) }
    let!(:project) { create :project, royalty_percentage: 100, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 1, project: project) }
    let!(:award1) { create :award, account: contributor, issuer: project.account, award_type: award_type, quantity: 50 }
    let!(:award2) { create :award, account: contributor, issuer: project.account, award_type: award_type, quantity: 50 }

    describe 'no revenue' do
      specify { expect(bystander.decorate.total_revenue_paid_pretty(project)).to eq '$0.00' }

      specify { expect(contributor.decorate.total_revenue_paid_pretty(project)).to eq '$0.00' }
    end

    describe 'with revenue' do
      let!(:revenue) { create :revenue, amount: 100, project: project }

      specify { expect(bystander.decorate.total_revenue_paid_pretty(project)).to eq '$0.00' }
      specify { expect(contributor.decorate.total_revenue_paid_pretty(project)).to eq '$0.00' }
      specify { expect(bystander.decorate.total_revenue_unpaid_remaining_pretty(project)).to eq '$0.00' }
      specify { expect(contributor.decorate.total_revenue_unpaid_remaining_pretty(project)).to eq '$100.00' }
    end

    describe 'with revenue and payments' do
      let!(:revenue) { create :revenue, amount: 100, project: project }
      let!(:payment1) { project.payments.create_with_quantity quantity_redeemed: 25, account: contributor }
      let!(:payment2) { project.payments.create_with_quantity quantity_redeemed: 14, account: contributor }

      specify { expect(bystander.decorate.total_revenue_paid_pretty(project)).to eq '$0.00' }
      specify { expect(contributor.decorate.total_revenue_paid_pretty(project)).to eq '$39.00' }
      specify { expect(bystander.decorate.total_revenue_unpaid_remaining_pretty(project)).to eq '$0.00' }
      specify { expect(contributor.decorate.total_revenue_unpaid_remaining_pretty(project)).to eq '$61.00' }
    end
  end
end
