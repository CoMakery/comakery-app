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

  describe '#can_send_awards?' do
    let!(:project_owner) { create(:account, ethereum_wallet: '0x3551cd3a70e07b3484f20d9480e677243870d67e') }

    context 'on ethereum network' do
      let!(:project) { create :project, payment_type: 'project_token' }
      let!(:project2) { build :project, payment_type: 'project_token', account: project_owner, ethereum_contract_address: '0x8023214bf21b1467be550d9b889eca672355c005' }

      it 'can send' do
        expect(project_owner.decorate.can_send_awards?(project2)).to be true
      end

      it 'cannot send' do
        expect(project_owner.decorate.can_send_awards?(project)).to be false
      end
    end

    context 'on bitcoin network' do
      let!(:recipient) { create(:account, bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps') }
      let!(:project) { build :project, payment_type: 'project_token', account: project_owner, coin_type: 'btc' }

      it 'can send' do
        expect(project_owner.decorate.can_send_awards?(project)).to be true
      end

      it 'cannot send' do
        project.coin_type = nil
        expect(project_owner.decorate.can_send_awards?(project)).to be false
      end
    end
  end

  describe '#can_receive_awards?' do
    context 'on ethereum network' do
      let!(:recipient) { create(:account, ethereum_wallet: '0x3551cd3a70e07b3484f20d9480e677243870d67e') }
      let!(:project) { build :project, payment_type: 'project_token', coin_type: 'eth' }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.ethereum_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'on bitcoin network' do
      let!(:recipient) { create(:account, bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps') }
      let!(:project) { build :project, payment_type: 'project_token', coin_type: 'btc' }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.bitcoin_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'on cardano network' do
      let!(:recipient) { create(:account, cardano_wallet: 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp') }
      let!(:project) { build :project, payment_type: 'project_token', coin_type: 'ada' }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.cardano_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'on qtum network' do
      let!(:recipient) { create(:account, qtum_wallet: 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM') }
      let!(:project) { build :project, payment_type: 'project_token', coin_type: 'qrc20' }

      it 'returns true' do
        expect(recipient.decorate.can_receive_awards?(project)).to be true
      end

      it 'returns false' do
        recipient.qtum_wallet = nil
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
    end

    context 'coin_type nil' do
      let!(:recipient) { create(:account, qtum_wallet: 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM') }
      let!(:project) { build :project, payment_type: 'project_token', coin_type: nil }

      it 'returns false' do
        expect(recipient.decorate.can_receive_awards?(project)).to be false
      end
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
