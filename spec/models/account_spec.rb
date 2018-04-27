require 'rails_helper'

describe Account do
  subject(:account) { create :account, password: '12345678' }

  before do
    stub_discord_channels
  end

  describe 'validations' do
    it 'requires many attributes' do
      expect(described_class.new.tap(&:valid?).errors.full_messages.sort).to eq(["Email can't be blank"])
    end

    it 'requires #ethereum_wallet to be a valid ethereum address' do
      expect(account.ethereum_wallet).to be_blank
      expect(account).to be_valid

      expect(account.tap { |a| a.update(ethereum_wallet: 'foo') }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: '0x') }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'a' * 39}") }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'a' * 41}") }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'g' * 40}") }.errors.full_messages).to eq(["Ethereum wallet should start with '0x', followed by a 40 character ethereum address"])

      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'a' * 40}") }).to be_valid
      expect(account.tap { |a| a.update(ethereum_wallet: "0x#{'A' * 40}") }).to be_valid
    end
  end

  it 'enforces unique emails, case-insensitively' do
    create :account, email: 'alice@example.com'
    expect { create :account, email: 'Alice@example.com' }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  # this is kind of unfortunate --
  # would be better with a "email-as-entered" field and
  # a separate lowercase "email-as-authenticated-username" field
  it 'makes emails all lowercase' do
    alice = create :account, email: 'ALICE@example.com'
    expect(alice.email).to eq('alice@example.com')
  end

  describe '#slack' do
    context 'creates a new Slack instance if none exists' do
      before do
        create :authentication, provider: 'slack', account: subject
        subject.instance_variable_set(:@slack, nil)
      end
      specify do
        expect(subject.slack).to be_instance_of Comakery::Slack
      end
    end

    context 'returns Slack instance if exists' do
      let!(:slack) { build :slack }

      before { subject.instance_variable_set(:@slack, slack) }
      specify do
        expect(subject.slack).to eq slack
      end
    end
  end

  describe '#slack_auth' do
    let!(:slack_authentication) { create(:authentication, provider: 'slack', account: subject) }
    let!(:other_authentication) { create(:authentication, provider: 'other', account: subject) }

    it "returns the authentication associated with this account that is from the 'slack' provider" do
      expect(subject.slack_auth).to eq(slack_authentication)
    end
  end

  describe '#send_award_notifications' do
    let!(:team) { create :team }
    let!(:project) { create :project, account: subject }
    let!(:award_type) { create :award_type, project: project }
    let!(:channel) { create :channel, team: team, project: project }
    let!(:award) { create :award, award_type: award_type, issuer: subject, channel: channel }

    before do
      create :authentication, provider: 'slack', account: subject
    end
    it 'sends a Slack notification' do
      allow(subject.slack).to receive(:send_award_notifications)
      subject.send_award_notifications award
      expect(subject.slack).to have_received(:send_award_notifications)
    end
  end

  describe 'authorize using password' do
    it 'does not accept invalid password' do
      expect(subject.authenticate('notright')).to be false
    end
    it 'returns account for valid password' do
      expect(subject.authenticate('12345678')).to eq subject
    end
  end

  describe 'associations' do
    it 'has many projects' do
      account = create(:account)
      project = create(:project, account_id: account.id)
      expect(account.projects).to match_array([project])
    end
  end

  describe '#name' do
    it 'returns the first and last name and falls back to the user name' do
      expect(build(:account, first_name: 'Bob', last_name: 'Johnson').decorate.name).to eq('Bob Johnson')
      expect(build(:account, first_name: nil, last_name: 'Johnson').decorate.name).to eq('Johnson')
      expect(build(:account, first_name: 'Bob', last_name: '').decorate.name).to eq('Bob')
    end
  end

  describe '#total_awards_earned' do
    let!(:contributor) { create(:account) }
    let!(:bystander) { create(:account) }
    let!(:project) { create :project, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:award1) { create :award, account: contributor, issuer: project.account, award_type: award_type }
    let!(:award2) { create :award, account: contributor, issuer: project.account, award_type: award_type, quantity: 3.5 }

    specify do
      expect(bystander.total_awards_earned(project)).to eq 0
    end

    specify do
      expect(contributor.total_awards_earned(project)).to eq 45
    end
  end

  describe '#total_awards_paid' do
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
      expect(bystander.total_awards_paid(project)).to eq 0
    end

    specify do
      expect(contributor.total_awards_paid(project)).to eq 11
    end
  end

  describe '#total_awards_remaining' do
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
      expect(bystander.total_awards_remaining(project)).to eq 0
    end

    specify do
      expect(contributor.total_awards_remaining(project)).to eq 9
    end
  end

  describe '#percent_unpaid' do
    let!(:account1) { create :account }
    let!(:account2) { create :account }
    let!(:project) { create :project, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 1, project: project) }
    let!(:revenue) { create :revenue, amount: 1000, project: project }

    specify { expect(account1.percent_unpaid(project)).to eq(0) }

    it 'handles divide by 0 risk' do
      award_type.awards.create_with_quantity(1, account: account1, issuer: project.account)
      expect(account1.percent_unpaid(project)).to eq(100)
    end

    it 'handles two awardees' do
      award_type.awards.create_with_quantity(1, account: account1, issuer: project.account)
      award_type.awards.create_with_quantity(1, account: account2, issuer: project.account)
      expect(account1.percent_unpaid(project)).to eq(50)
    end

    it 'calculates only unpaid awards' do
      award_type.awards.create_with_quantity(6, account: account1, issuer: project.account)
      award_type.awards.create_with_quantity(6, account: account2, issuer: project.account)
      expect(account1.percent_unpaid(project)).to eq(50)

      project.payments.create_with_quantity(quantity_redeemed: 2, account: account1)
      expect(account1.percent_unpaid(project)).to eq(40)
      expect(account2.percent_unpaid(project)).to eq(60)

      project.payments.create_with_quantity(quantity_redeemed: 5, account: account2)
      expect(account1.percent_unpaid(project)).to eq(80)
      expect(account2.percent_unpaid(project)).to eq(20)
    end

    it 'returns 8 decimal point precision BigDecimal' do
      award_type.awards.create_with_quantity(1, account: account1, issuer: project.account)
      award_type.awards.create_with_quantity(2, account: account2, issuer: project.account)

      expect(account1.percent_unpaid(project)).to eq(BigDecimal('33.' + ('3' * 8)))
      expect(account2.percent_unpaid(project)).to eq(BigDecimal('66.' + ('6' * 8)))
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
      specify { expect(bystander.total_revenue_paid(project)).to eq 0 }

      specify { expect(contributor.total_revenue_paid(project)).to eq 0 }
    end

    describe 'with revenue' do
      let!(:revenue) { create :revenue, amount: 100, project: project }

      specify { expect(bystander.total_revenue_paid(project)).to eq 0 }
      specify { expect(contributor.total_revenue_paid(project)).to eq 0 }
      specify { expect(bystander.total_revenue_unpaid(project)).to eq 0 }
      specify { expect(contributor.total_revenue_unpaid(project)).to eq 100 }
    end

    describe 'with revenue and payments' do
      let!(:revenue) { create :revenue, amount: 100, project: project }
      let!(:payment1) { project.payments.create_with_quantity quantity_redeemed: 25, account: contributor }
      let!(:payment2) { project.payments.create_with_quantity quantity_redeemed: 14, account: contributor }

      specify { expect(bystander.total_revenue_paid(project)).to eq 0 }
      specify { expect(contributor.total_revenue_paid(project)).to eq 39 }
      specify { expect(bystander.total_revenue_unpaid(project)).to eq 0 }
      specify { expect(contributor.total_revenue_unpaid(project)).to eq 61 }
    end
  end
end
