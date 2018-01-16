require 'rails_helper'

describe Authentication do
  describe 'validations' do
    it 'requires many attributes' do
      errors = described_class.new.tap(&:valid?).errors.full_messages
      expect(errors.sort).to eq([
                                  "Account can't be blank",
                                  "Provider can't be blank",
                                  "Slack team can't be blank",
                                  "Slack team image 132 url can't be blank",
                                  "Slack team image 34 url can't be blank",
                                  "Slack team name can't be blank",
                                  "Slack user can't be blank",
                                  "Slack user name can't be blank"
                                ])
    end

    it 'requires a valid slack team domain' do
      expect(described_class.new(slack_team_domain: '').tap(&:valid?).errors.full_messages).to be_include("Slack team domain can't be blank")
      expect(described_class.new(slack_team_domain: 'XX').tap(&:valid?).errors.full_messages).to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
      expect(described_class.new(slack_team_domain: '-xx').tap(&:valid?).errors.full_messages).to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
      expect(described_class.new(slack_team_domain: "good\n-bad").tap(&:valid?).errors.full_messages).to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')

      expect(described_class.new(slack_team_domain: '3-xx').tap(&:valid?).errors.full_messages).not_to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
      expect(described_class.new(slack_team_domain: 'a').tap(&:valid?).errors.full_messages).not_to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
    end
  end

  describe 'associations' do
    it 'has many projects' do
      project = create(:project)
      expect(create(:authentication, slack_team_id: project.slack_team_id).projects).to match_array([project])
    end
  end

  describe '#display_name' do
    it 'returns the first and last name and falls back to the user name' do
      expect(build(:authentication, slack_first_name: 'Bob', slack_last_name: 'Johnson', slack_user_name: 'bj').display_name).to eq('Bob Johnson')
      expect(build(:authentication, slack_first_name: nil, slack_last_name: 'Johnson', slack_user_name: 'bj').display_name).to eq('Johnson')
      expect(build(:authentication, slack_first_name: 'Bob', slack_last_name: '', slack_user_name: 'bj').display_name).to eq('Bob')
      expect(build(:authentication, slack_first_name: nil, slack_last_name: '', slack_user_name: 'bj').display_name).to eq('@bj')
    end
  end

  describe '#percent_unpaid' do
    let!(:auth1) { create :authentication }
    let!(:auth2) { create :authentication }
    let!(:project) { create :project, payment_type: 'revenue_share' }
    let!(:award_type) { create(:award_type, amount: 1, project: project) }
    let!(:revenue) { create :revenue, amount: 1000, project: project }

    specify { expect(auth1.percent_unpaid(project)).to eq(0) }

    it 'handles divide by 0 risk' do
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: auth1)
      expect(auth1.percent_unpaid(project)).to eq(100)
    end

    it 'handles two awardees' do
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: auth1)
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: auth2)
      expect(auth1.percent_unpaid(project)).to eq(50)
    end

    it 'calculates only unpaid awards' do
      award_type.awards.create_with_quantity(6, issuer: project.owner_account, authentication: auth1)
      award_type.awards.create_with_quantity(6, issuer: project.owner_account, authentication: auth2)
      expect(auth1.percent_unpaid(project)).to eq(50)

      project.payments.create_with_quantity(quantity_redeemed: 2, payee_auth: auth1)
      expect(auth1.percent_unpaid(project)).to eq(40)
      expect(auth2.percent_unpaid(project)).to eq(60)

      project.payments.create_with_quantity(quantity_redeemed: 5, payee_auth: auth2)
      expect(auth1.percent_unpaid(project)).to eq(80)
      expect(auth2.percent_unpaid(project)).to eq(20)
    end

    it 'returns 8 decimal point precision BigDecimal' do
      award_type.awards.create_with_quantity(1, issuer: project.owner_account, authentication: auth1)
      award_type.awards.create_with_quantity(2, issuer: project.owner_account, authentication: auth2)

      expect(auth1.percent_unpaid(project)).to eq(BigDecimal('33.' + ('3' * 8)))
      expect(auth2.percent_unpaid(project)).to eq(BigDecimal('66.' + ('6' * 8)))
    end
  end

  describe '#total_awards_earned' do
    let!(:contributor) { create(:authentication) }
    let!(:bystander) { create(:authentication) }
    let!(:project) { create :project, payment_type: 'revenue_share'  }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:award1) { create :award, authentication: contributor, award_type: award_type }
    let!(:award2) { create :award, authentication: contributor, award_type: award_type, quantity: 3.5 }

    specify do
      expect(bystander.total_awards_earned(project)).to eq 0
    end

    specify do
      expect(contributor.total_awards_earned(project)).to eq 45
    end
  end

  describe '#total_awards_paid' do
    let!(:issuer) { create(:authentication) }
    let!(:contributor) { create(:authentication) }
    let!(:bystander) { create(:authentication) }
    let!(:project) { create :project, payment_type: 'revenue_share'  }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:revenue) { create :revenue, amount: 1000, project: project }

    before do
      award_type.awards.create_with_quantity(2, issuer: project.owner_account, authentication: contributor)
      project.payments.create_with_quantity(quantity_redeemed: 10, payee_auth: contributor)
      project.payments.create_with_quantity(quantity_redeemed: 1, payee_auth: contributor)
    end

    specify do
      expect(bystander.total_awards_paid(project)).to eq 0
    end

    specify do
      expect(contributor.total_awards_paid(project)).to eq 11
    end
  end

  describe '#total_awards_remaining' do
    let!(:issuer) { create(:authentication) }
    let!(:contributor) { create(:authentication) }
    let!(:bystander) { create(:authentication) }
    let!(:project) { create :project, payment_type: 'revenue_share'  }
    let!(:revenue) { create :revenue, amount: 1000, project: project }
    let!(:award_type) { create(:award_type, amount: 10, project: project) }
    let!(:award1) { create :award, authentication: contributor, award_type: award_type }
    let!(:award2) { create :award, authentication: contributor, award_type: award_type }
    let!(:payment1) { project.payments.create_with_quantity(quantity_redeemed: 10, payee_auth: contributor) }
    let!(:payment2) { project.payments.create_with_quantity(quantity_redeemed: 1, payee_auth: contributor) }

    specify do
      expect(bystander.total_awards_remaining(project)).to eq 0
    end

    specify do
      expect(contributor.total_awards_remaining(project)).to eq 9
    end
  end

  describe 'revenue' do
    let!(:contributor) { create(:authentication) }
    let!(:bystander) { create(:authentication) }
    let!(:project) { create :project, royalty_percentage: 100, payment_type: 'revenue_share'  }
    let!(:award_type) { create(:award_type, amount: 1, project: project) }
    let!(:award1) { create :award, authentication: contributor, award_type: award_type, quantity: 50 }
    let!(:award2) { create :award, authentication: contributor, award_type: award_type, quantity: 50 }

    describe '#total_revenue_paid' do
      describe 'no revenue' do
        specify { expect(bystander.total_revenue_paid(project)).to eq 0 }

        specify { expect(contributor.total_revenue_paid(project)).to eq 0 }
      end

      describe 'with revenue' do
        let!(:revenue) { create :revenue, amount: 100, project: project }

        specify { expect(bystander.total_revenue_paid(project)).to eq 0 }

        specify { expect(contributor.total_revenue_paid(project)).to eq 0 }
      end

      describe 'with revenue and payments' do
        let!(:revenue) { create :revenue, amount: 100, project: project }
        let!(:payment1) { project.payments.create_with_quantity quantity_redeemed: 25, payee_auth: contributor }
        let!(:payment2) { project.payments.create_with_quantity quantity_redeemed: 14, payee_auth: contributor }

        specify { expect(bystander.total_revenue_paid(project)).to eq 0 }

        specify { expect(contributor.total_revenue_paid(project)).to eq 39 }
      end
    end

    describe '#total_revenue_unpaid' do
      describe 'no revenue' do
        specify { expect(bystander.total_revenue_unpaid(project)).to eq 0 }

        specify { expect(contributor.total_revenue_unpaid(project)).to eq 0 }
      end

      describe 'with revenue' do
        let!(:revenue) { create :revenue, amount: 100, project: project }

        specify { expect(bystander.total_revenue_unpaid(project)).to eq 0 }

        specify { expect(contributor.total_revenue_unpaid(project)).to eq 100 }
      end

      describe 'with revenue and payments' do
        let!(:revenue) { create :revenue, amount: 100, project: project }
        let!(:payment1) { project.payments.create_with_quantity quantity_redeemed: 25, payee_auth: contributor }
        let!(:payment2) { project.payments.create_with_quantity quantity_redeemed: 14, payee_auth: contributor }

        specify { expect(bystander.total_revenue_unpaid(project)).to eq 0 }

        specify { expect(contributor.total_revenue_unpaid(project)).to eq 61 }
      end
    end
  end

  describe '#slack_icon' do
    it 'returns the slack_image_32 and falls back on the slack_team_image_34 if not available' do
      expect(build(:authentication, slack_team_image_34_url: 'http://team.jpg').slack_icon).to eq('http://team.jpg')
      expect(build(:authentication, slack_team_image_34_url: 'http://team.jpg', slack_image_32_url: 'http://user.jpg').slack_icon).to eq('http://user.jpg')
    end
  end

  describe 'slack_team_ethereum_enabled?' do
    describe 'when ENV whitelist is set' do
      before do
        Rails.application.config.allow_ethereum = 'foo,comakery'
      end
      it 'is true if the slack team domain is in the ENV whitelist' do
        auth = create(:authentication, slack_team_domain: 'comakery')
        expect(auth.slack_team_ethereum_enabled?).to eq true
      end
      it 'is false if the slack team domain is not in the ENV whitelist' do
        auth = create(:authentication, slack_team_domain: 'com0kery')
        expect(auth.slack_team_ethereum_enabled?).to eq false
      end
      it 'is false if the slack team domain is nil' do
        auth = create(:authentication, slack_team_domain: nil)
        expect(auth.slack_team_ethereum_enabled?).to eq false
      end
    end

    describe 'when ENV whitelist is nil' do
      before do
        Rails.application.config.allow_ethereum = nil
      end
      it 'is false for a valid slack team domain' do
        auth = create(:authentication, slack_team_domain: 'comakery')
        expect(auth.slack_team_ethereum_enabled?).to eq false
      end
      it 'is false if the slack team domain is nil' do
        auth = create(:authentication, slack_team_domain: nil)
        expect(auth.slack_team_ethereum_enabled?).to eq false
      end
    end

    describe 'when ENV whitelist is empty' do
      before do
        Rails.application.config.allow_ethereum = ''
      end
      it 'is false for a valid domain' do
        auth = create(:authentication, slack_team_domain: 'comakery')
        expect(auth.slack_team_ethereum_enabled?).to eq false
      end
      it 'is false if the slack team domain is nil' do
        auth = create(:authentication, slack_team_domain: nil)
        expect(auth.slack_team_ethereum_enabled?).to eq false
      end
    end
  end

  describe '.find_or_create_from_auth_hash' do
    let(:auth_hash) do
      {
        'provider' => 'slack',
        'credentials' => {
          'token' => 'xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa'
        },
        'extra' => {
          'user_info' => { 'user' => { 'profile' => { 'email' => 'bob@example.com', 'image_32' => 'https://avatars.com/avatars_32.jpg' } } },
          'team_info' => {
            'team' => {
              'icon' => {
                'image_34' => 'https://slack.example.com/team-image-34-px.jpg',
                'image_132' => 'https://slack.example.com/team-image-132px.jpg'
              }
            }
          }
        },
        'info' => {
          'name' => 'Bob Roberts',
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'user_id' => 'slack user id',
          'team' => 'new team name',
          'team_id' => 'slack team id',
          'user' => 'bobroberts',
          'team_domain' => 'bobrobertsdomain'
        }
      }
    end

    context 'when nothing changed from last login' do
      it 'updates the timestamp on the authentications' do
        travel_to Date.new 2015
        account = described_class.find_or_create_from_auth_hash!(auth_hash)
        travel_to Date.new 2016
        expect do
          described_class.find_or_create_from_auth_hash!(auth_hash)
        end.to change { account.slack_auth.reload.updated_at }
      end
    end

    context 'when no account exists yet' do
      it 'creates an account and authentications for that account' do
        account = described_class.find_or_create_from_auth_hash!(auth_hash)

        expect(account.email).to eq('bob@example.com')

        auth = account.authentications.first

        expect(auth.provider).to eq('slack')
        expect(auth.slack_user_name).to eq('bobroberts')
        expect(auth.slack_first_name).to eq('Bob')
        expect(auth.slack_last_name).to eq('Roberts')
        expect(auth.slack_team_name).to eq('new team name')
        expect(auth.slack_team_id).to eq('slack team id')
        expect(auth.slack_user_id).to eq('slack user id')
        expect(auth.slack_token).to eq('xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa')
        expect(auth.slack_team_domain).to eq('bobrobertsdomain')
        expect(auth.slack_image_32_url).to eq('https://avatars.com/avatars_32.jpg')
        expect(auth.oauth_response).to eq(auth_hash)
      end
    end

    context 'when there are missing credentials' do
      it 'blows up' do
        expect do
          expect do
            expect do
              described_class.find_or_create_from_auth_hash!({})
            end.to raise_error(SlackAuthHash::MissingAuthParamException)
          end.not_to change { Account.count }
        end.not_to change { described_class.count }
      end
    end

    context 'when there is a related account' do
      let!(:account) { create(:account, email: 'bob@example.com') }
      let!(:authentication) do
        create(:authentication,
          account_id: account.id,
          provider: 'slack',
          slack_user_id: 'slack user id',
          slack_team_id: 'slack team id',
          slack_token: 'slack token')
      end

      let!(:project) do
        create(:project,
          slack_team_id: 'slack team id',
          slack_team_name: 'old team name')
      end

      it 'returns the existing account' do
        result = nil
        expect do
          expect do
            result = described_class.find_or_create_from_auth_hash!(auth_hash)
          end.not_to change { Account.count }
        end.not_to change { described_class.count }

        expect(result.id).to eq(account.id)
      end

      it 'updates team info for projects with the same slack_team_id' do
        result = described_class.find_or_create_from_auth_hash!(auth_hash)
        project.reload
        expect(project.reload.slack_team_name).to eq('new team name')
      end
    end
  end
end
