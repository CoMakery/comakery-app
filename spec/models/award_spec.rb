require 'rails_helper'

describe Award do
  describe 'associations' do
    let(:specialty) { create(:specialty) }
    let(:award) { create(:award, specialty: specialty) }

    it 'has the expected associations' do
      described_class.create!(
        name: 'test',
        why: 'test',
        description: 'test',
        requirements: 'test',
        proof_link: 'http://none',
        proof_id: 'xyz123',
        issuer: create(:account),
        account: create(:account),
        award_type: create(:award_type),
        amount: 50,
        quantity: 2
      )
    end

    it 'has_many assignments' do
      award = create(:award_ready)
      2.times { award.clone_on_assignment }

      expect(award.assignments.size).to eq(2)
    end

    it 'belongs to cloned_from' do
      award = create(:award_ready)
      award.clone_on_assignment

      expect(award.assignments.first.cloned_from).to eq(award)
    end

    it 'belongs to specialty' do
      expect(award.specialty).to eq(specialty)
    end
  end

  describe 'scopes' do
    before do
      described_class.statuses.each_key { |status| (create :award).update(status: status) }
    end

    it '.completed returns only accepted and paid awards' do
      described_class.statuses.each_key do |status|
        if %w[accepted paid].include? status
          expect(described_class.completed.pluck(:status).include?(status)).to be_truthy
        else
          expect(described_class.completed.pluck(:status).include?(status)).to be_falsey
        end
      end
    end

    it '.listed returns all but cancelled and unpublished awards' do
      described_class.statuses.each_key do |status|
        if %w[cancelled unpublished].include? status
          expect(described_class.listed.pluck(:status).include?(status)).to be_falsey
        else
          expect(described_class.listed.pluck(:status).include?(status)).to be_truthy
        end
      end
    end

    it '.in_progress returns all but rejected, paid, cancelled and unpublished awards' do
      described_class.statuses.each_key do |status|
        if %w[rejected paid cancelled unpublished].include? status
          expect(described_class.in_progress.pluck(:status).include?(status)).to be_falsey
        else
          expect(described_class.in_progress.pluck(:status).include?(status)).to be_truthy
        end
      end
    end

    it '.contributed returns all but ready, cancelled and unpublished awards' do
      described_class.statuses.each_key do |status|
        if %w[ready cancelled unpublished].include? status
          expect(described_class.contributed.pluck(:status).include?(status)).to be_falsey
        else
          expect(described_class.contributed.pluck(:status).include?(status)).to be_truthy
        end
      end
    end

    describe '.filtered_for_view(filter, account)' do
      let(:award_type) { create(:award_type) }
      let(:award_ready_w_account) { create :award_ready, award_type: award_type }
      let(:award_ready_wo_account) { create :award_ready, award_type: award_type }
      let(:award_started) { create :award, status: :started, award_type: award_type }
      let(:award_submitted) { create :award, status: :submitted, award_type: award_type }
      let(:award_accepted) { create :award, status: :accepted, award_type: award_type }
      let(:award_paid) { create :award, status: :paid, award_type: award_type }
      let(:award_rejected) { create :award, status: :rejected, award_type: award_type }

      before do
        award_ready_wo_account.update(account: nil)
        award_type.project.admins << create(:account)
      end

      it 'returns only ready awards without assigned account or assigned to you' do
        expect(described_class.filtered_for_view('ready', create(:account))).to include(award_ready_wo_account)
        expect(described_class.filtered_for_view('ready', award_ready_w_account.account)).to include(award_ready_w_account)

        expect(described_class.filtered_for_view('ready', create(:account))).not_to include(award_ready_w_account)
      end

      it 'returns only started awards for a contributor' do
        expect(described_class.filtered_for_view('started', award_started.account)).to include(award_started)

        expect(described_class.filtered_for_view('started', create(:account))).not_to include(award_started)
        expect(described_class.filtered_for_view('started', award_ready_w_account.account)).not_to include(award_ready_w_account)
      end

      it 'returns only submitted or accepted awards for a contributor' do
        expect(described_class.filtered_for_view('submitted', award_submitted.account)).to include(award_submitted)
        expect(described_class.filtered_for_view('submitted', award_accepted.account)).to include(award_accepted)

        expect(described_class.filtered_for_view('submitted', create(:account))).not_to include(award_submitted)
        expect(described_class.filtered_for_view('submitted', award_ready_w_account.account)).not_to include(award_ready_w_account)
        expect(described_class.filtered_for_view('submitted', award_started.account)).not_to include(award_started)
      end

      it 'returns only awards available for review for project admin/owner' do
        expect(described_class.filtered_for_view('to review', award_submitted.project.account)).to include(award_submitted)
        expect(described_class.filtered_for_view('to review', award_submitted.project.admins.first)).to include(award_submitted)

        expect(described_class.filtered_for_view('to review', award_submitted.account)).not_to include(award_submitted)
        expect(described_class.filtered_for_view('to review', create(:account))).not_to include(award_submitted)
      end

      it 'returns only awards available for payment for a project admin/owner' do
        expect(described_class.filtered_for_view('to pay', award_accepted.project.account)).to include(award_accepted)
        expect(described_class.filtered_for_view('to pay', award_accepted.project.admins.first)).to include(award_accepted)

        expect(described_class.filtered_for_view('to pay', award_accepted.account)).not_to include(award_accepted)
        expect(described_class.filtered_for_view('to pay', create(:account))).not_to include(award_accepted)
        expect(described_class.filtered_for_view('to pay', award_submitted.project.account)).not_to include(award_submitted)
      end

      it 'returns only paid or rejected awards' do
        expect(described_class.filtered_for_view('done', award_paid.account)).to include(award_paid)
        expect(described_class.filtered_for_view('done', award_paid.project.account)).to include(award_paid)
        expect(described_class.filtered_for_view('done', award_rejected.account)).to include(award_rejected)
        expect(described_class.filtered_for_view('done', award_rejected.project.account)).to include(award_rejected)

        expect(described_class.filtered_for_view('done', create(:account))).not_to include(award_paid)
        expect(described_class.filtered_for_view('done', create(:account))).not_to include(award_rejected)
        expect(described_class.filtered_for_view('to pay', award_accepted.account)).not_to include(award_accepted)
        expect(described_class.filtered_for_view('to pay', award_submitted.project.account)).not_to include(award_submitted)
      end

      it 'returns no awards for an unknown filter' do
        expect(described_class.filtered_for_view('not finished', award_paid.account)).to eq([])
      end
    end
  end

  describe 'hooks' do
    describe 'set_paid_status_if_project_has_no_token' do
      let!(:submtted_task_w_no_token) { create(:award, status: 'submitted') }
      let!(:submtted_task_w_token) { create(:award, status: 'submitted') }

      before do
        submtted_task_w_no_token.project.update(token: nil)
        submtted_task_w_no_token.update(status: 'accepted')
        submtted_task_w_token.update(status: 'accepted')
      end

      it 'upgrades accepted task to paid immediately if project has no token associated' do
        expect(submtted_task_w_no_token.paid?).to be true
      end

      it 'doesnt upgrade accepted task to paid if project has token associated' do
        expect(submtted_task_w_token.accepted?).to be true
      end
    end

    describe 'make_unpublished_if_award_type_is_not_ready' do
      let!(:award_type_draft) { create(:award_type, state: :draft) }
      let!(:award_ready_draft) { create(:award_ready, award_type: award_type_draft) }
      let!(:award_done_draft) { create(:award, award_type: award_type_draft) }
      let!(:award_ready) { create(:award_ready) }

      it 'sets status to unpublished if award_type is not ready and award is in ready state' do
        expect(award_ready_draft.unpublished?).to be_truthy
      end

      it 'doesnt set status to unpublished if award_type is ready' do
        expect(award_ready.unpublished?).to be_falsey
      end

      it 'doesnt set status to unpublished if award is not in ready state' do
        expect(award_done_draft.unpublished?).to be_falsey
      end
    end

    describe 'update_account_experience' do
      let!(:award_ready) { create(:award_ready) }

      it 'increases contributor experience when award is completed' do
        expect do
          award_ready.update(status: :accepted)
        end.to change { Experience.find_by(account: award_ready.account, specialty: award_ready.specialty)&.level.to_i }.by(1)
      end
    end

    describe 'set_default_specialty' do
      let!(:award) { create(:award_ready) }

      it 'sets default specialty' do
        expect(award.specialty).to eq(Specialty.default)
      end
    end

    describe 'set_expires_at' do
      let!(:award) { create(:award, status: :started, expires_in_days: 1) }

      it 'sets expires_at timestamp using expires_in_days value' do
        expect(award.expires_at).to eq(award.expires_in_days.days.since(award.updated_at))
      end

      it 'sets notify_on_expiration_at timestamp using 3/4 of expires_in_days value' do
        expect(award.notify_on_expiration_at).to eq((award.expires_in_days.days * 0.75).since(award.updated_at))
      end
    end

    describe 'clear_expires_at' do
      let!(:award) { create(:award, status: :started, expires_in_days: 1) }

      before do
        award.update(status: :submitted, submission_comment: 'dummy')
        award.reload
      end

      it 'clears expires_at timestamp when status is submitted' do
        expect(award.expires_at).to be_nil
      end

      it 'clears notify_on_expiaration_at timestamp when status is submitted' do
        expect(award.notify_on_expiration_at).to be_nil
      end
    end

    describe 'store_license_hash' do
      let!(:project) { create(:project) }
      let!(:award_ready) { create(:award_ready, award_type: create(:award_type, project: project)) }
      let!(:award_ready_w_license) { create(:award_ready, agreed_to_license_hash: 'present', award_type: create(:award_type, project: project)) }

      it 'stores the hash of the project CP license when the task is started' do
        award_ready.update(status: :started)
        expect(award_ready.reload.agreed_to_license_hash).to eq(project.reload.agreed_to_license_hash)
      end

      it 'doesnt update the hash if its already present' do
        award_ready_w_license.update(status: :started)
        expect(award_ready_w_license.reload.agreed_to_license_hash).to eq('present')
      end
    end
  end

  describe 'validations' do
    it 'requires things be present' do
      expect(described_class.new(quantity: nil).tap(&:valid?).errors.full_messages).to match_array([
                                                                                                     "Award type can't be blank",
                                                                                                     "Name can't be blank",
                                                                                                     "Why can't be blank",
                                                                                                     "Requirements can't be blank",
                                                                                                     'Amount is not a number'
                                                                                                   ])
    end

    it 'requires number_of_assignments to be greater than 0' do
      a = create(:award_ready)
      a.update(number_of_assignments: 0)
      expect(a).not_to be_valid
    end

    it 'requires number_of_assignments_per_user to be greater than 0' do
      a = create(:award_ready)
      a.update(number_of_assignments_per_user: 0)
      expect(a).not_to be_valid
    end

    it 'requires expires_in_days to be greater than 0' do
      a = create(:award_ready)
      a.update(expires_in_days: 0)
      expect(a).not_to be_valid
    end

    it 'requires number_of_assignments_per_user to be less or equal to number_of_assignments' do
      a = create(:award_ready)
      a.update(number_of_assignments: 1, number_of_assignments_per_user: 1)
      expect(a).to be_valid
      a.update(number_of_assignments: 2, number_of_assignments_per_user: 1)
      expect(a).to be_valid
      a.update(number_of_assignments: 1, number_of_assignments_per_user: 2)
      expect(a).not_to be_valid
    end

    it 'requires submission fields when in submitted status' do
      a = create(:award_ready)
      a.update(status: 'submitted', account: create(:account))
      expect(a).not_to be_valid
      expect(a.errors.full_messages).to eq(["Submission comment can't be blank"])
    end

    it 'cannot be assigned to a contributor having more than allowed number of started tasks' do
      a = create(:award)
      c = create(:account)
      Award::STARTED_TASKS_PER_CONTRIBUTOR.times { create(:award, status: 'started', account: c) }
      a.update(status: 'started', account: c)
      expect(a).not_to be_valid
      expect(a.errors.full_messages).to eq(["Sorry, you can't start more than #{Award::STARTED_TASKS_PER_CONTRIBUTOR} tasks"])
    end

    it 'cannot be destroyed unless in ready or unpublished status' do
      described_class.statuses.keys.each do |status|
        a = create(:award)
        a.update(status: status)
        if %w[ready unpublished].include? status
          expect { a.destroy }.to(change { described_class.count }.by(-1))
        else
          expect { a.destroy }.not_to(change { described_class.count })
          expect(a.errors[:base].first).to eq("#{status.capitalize} task can't be deleted")
        end
      end
    end

    it 'allows only predefined experience levels' do
      [0, 2, 3, 10, 10000].each do |level|
        a = create(:award)
        a.experience_level = level
        if Award::EXPERIENCE_LEVELS.values.include?(level)
          expect(a).to be_valid
        else
          expect(a).not_to be_valid
          expect(a.errors.full_messages.first).to eq('Experience level is not included in the list')
        end
      end
    end

    describe 'awards amounts must be > 0' do
      let(:award) { build :award }

      specify do
        award.quantity = -1
        expect(award.valid?).to eq(false)
        expect(award.errors[:quantity]).to eq(['must be greater than 0'])
      end

      specify do
        award.amount = -1
        expect(award.valid?).to eq(false)
        expect(award.errors[:amount]).to eq(['must be greater than 0'])
      end
    end

    describe 'total_amount calculation' do
      let(:award_w_quantity) { create :award, amount: 100, quantity: 2 }
      let(:award_template) { create :award, amount: 100, number_of_assignments: 3 }

      it 'multiplies amount by quantity' do
        expect(award_w_quantity.total_amount).to eq(200)
      end
    end

    describe '#ethereum_transaction_address' do
      let(:project) { create(:project, token: create(:token, coin_type: 'erc20')) }
      let(:award_type) { create(:award_type, project: project) }
      let(:award) { create(:award, award_type: award_type) }
      let(:address) { '0x' + 'a' * 64 }

      it 'validates with a valid ethereum transaction address' do
        expect(build(:award, ethereum_transaction_address: nil)).to be_valid
        expect(build(:award, ethereum_transaction_address: "0x#{'a' * 64}")).to be_valid
        expect(build(:award, ethereum_transaction_address: "0x#{'A' * 64}")).to be_valid
      end

      it 'does not validate with an invalid ethereum transaction address' do
        expected_error_message = "Ethereum transaction address should start with '0x', followed by a 64 character ethereum address"
        expect(award.tap { |o| o.ethereum_transaction_address = 'foo' }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = '0x' }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = "0x#{'a' * 63}" }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = "0x#{'a' * 65}" }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = "0x#{'g' * 64}" }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end

      it { expect(award.ethereum_transaction_address).to eq(nil) }

      it 'can be set' do
        award.ethereum_transaction_address = address
        award.save!
        award.reload
        expect(award.ethereum_transaction_address).to eq(address)
      end

      it 'once set cannot be set unset' do
        award.ethereum_transaction_address = address
        award.save!
        award.ethereum_transaction_address = nil
        expect(award).not_to be_valid
        expect(award.errors.full_messages.to_sentence).to match \
          /Ethereum transaction address cannot be changed after it has been set/
      end

      it 'once set it cannot be set to another value' do
        award.ethereum_transaction_address = address
        award.save!
        award.ethereum_transaction_address = '0x' + 'b' * 64
        expect(award).not_to be_valid
        expect(award.errors.full_messages.to_sentence).to match \
          /Ethereum transaction address cannot be changed after it has been set/
      end
    end

    describe '#ethereum_transaction_address on qtum network' do
      let(:project) { create(:project, token: create(:token, coin_type: 'qrc20')) }
      let(:award_type) { create(:award_type, project: project) }
      let(:award) { create(:award, award_type: award_type) }
      let(:address) { 'a' * 64 }

      it 'validates with a valid ethereum transaction address' do
        expect(build(:award, ethereum_transaction_address: nil)).to be_valid
        expect(build(:award, ethereum_transaction_address: ('a' * 64).to_s)).to be_valid
        expect(build(:award, ethereum_transaction_address: ('A' * 64).to_s)).to be_valid
      end

      it 'does not validate with an invalid ethereum transaction address' do
        expected_error_message = "Ethereum transaction address should have 64 characters, should not start with '0x'"
        expect(award.tap { |o| o.ethereum_transaction_address = 'foo' }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = "0x#{'a' * 62}" }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = ('a' * 65).to_s }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(award.tap { |o| o.ethereum_transaction_address = ('g' * 64).to_s }.tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end

      it { expect(award.ethereum_transaction_address).to eq(nil) }

      it 'can be set' do
        award.ethereum_transaction_address = address
        award.save!
        award.reload
        expect(award.ethereum_transaction_address).to eq(address)
      end

      it 'once set cannot be set unset' do
        award.ethereum_transaction_address = address
        award.save!
        award.ethereum_transaction_address = nil
        expect(award).not_to be_valid
        expect(award.errors.full_messages.to_sentence).to match \
          /Ethereum transaction address cannot be changed after it has been set/
      end

      it 'once set it cannot be set to another value' do
        award.ethereum_transaction_address = address
        award.save!
        award.ethereum_transaction_address = 'b' * 64
        expect(award).not_to be_valid
        expect(award.errors.full_messages.to_sentence).to match \
          /Ethereum transaction address cannot be changed after it has been set/
      end
    end
  end

  describe '.matching_experience_for?(account)' do
    let(:account) { create(:account) }
    let(:award_type) { create(:award_type) }
    let(:award_no_experience) { create(:award_ready, specialty: account.specialty, award_type: award_type) }
    let(:award_level1) { create(:award_ready, experience_level: Award::EXPERIENCE_LEVELS['New Contributor'], award_type: award_type) }
    let(:award_level2) { create(:award_ready, experience_level: Award::EXPERIENCE_LEVELS['Demonstrated Skills'], award_type: award_type) }
    let(:award_level3) { create(:award_ready, experience_level: Award::EXPERIENCE_LEVELS['Established Contributor'], award_type: award_type) }

    before do
      described_class.destroy_all
      Award::EXPERIENCE_LEVELS['Demonstrated Skills'].times { create(:award, account: account, award_type: award_type) }
    end

    it 'returns true if account experience is greater than award requirement' do
      expect(award_level1.matching_experience_for?(account)).to be_truthy
    end

    it 'returns true if account experience is equal to award requirement' do
      expect(award_level2.matching_experience_for?(account)).to be_truthy
    end

    it 'returns false if account experience is less than award requirement' do
      expect(award_level3.matching_experience_for?(account)).to be_falsey
    end
  end

  describe '#total_amount should no be round' do
    specify do
      award = create :award, quantity: 1.4, amount: 1
      award.reload
      expect(award.total_amount).to eq(0.14e1)
    end

    specify do
      award = create :award, quantity: 1.5, amount: 1
      award.reload
      expect(award.total_amount).to eq(0.15e1)
    end
  end

  describe '.total_awarded' do
    describe 'without project awards' do
      specify { expect(described_class.total_awarded).to eq(0) }
    end

    describe 'with project awards' do
      let!(:project1) { create :project, token: create(:token, coin_type: 'erc20') }
      let!(:project1_award_type) { (create :award_type, project: project1) }
      let(:project2) { create :project, token: create(:token, coin_type: 'erc20') }
      let!(:project2_award_type) { (create :award_type, project: project2) }
      let(:account) { create :account }

      before do
        create(:award, award_type: project1_award_type, quantity: 5, amount: 3, issuer: project1.account, account: account)
        create(:award, award_type: project1_award_type, quantity: 5, amount: 3, issuer: project1.account, account: account)

        create(:award, award_type: project2_award_type, quantity: 3, amount: 5, issuer: project2.account, account: account)
        create(:award, award_type: project2_award_type, quantity: 7, amount: 5, issuer: project2.account, account: account)
      end

      it 'is able to scope to a project' do
        expect(project1.awards.total_awarded).to eq(30)
        expect(project2.awards.total_awarded).to eq(50)
      end

      it 'returns the total amount of awards issued' do
        expect(described_class.total_awarded).to eq(80)
      end
    end
  end

  describe 'helper methods' do
    let!(:team) { create :team }
    let!(:team1) { create :team, provider: 'discord' }
    let!(:account) { create :account, email: 'reciver@test.st' }
    let!(:authentication) { create :authentication, account: account }
    let!(:account1) { create :account }
    let!(:authentication1) { create :authentication, account: account1, provider: 'discord' }
    let!(:project) { create :project, account: account, token: create(:token, coin_type: 'erc20') }
    let!(:award_type) { (create :award_type, project: project) }
    let!(:award) { create :award, award_type: award_type, amount: 3, issuer: account, account: account }
    let!(:award1) { create :award, award_type: award_type, amount: 3, issuer: account, account: account1 }

    before do
      team.build_authentication_team authentication
      team1.build_authentication_team authentication1
      stub_discord_channels
      project.channels.create(team: team1, channel_id: 'general')
    end

    it 'check for ethereum issue ready' do
      expect(award.ethereum_issue_ready?).to be_falsey

      project.token.update ethereum_enabled: true
      account.update ethereum_wallet: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423'

      expect(award.reload.ethereum_issue_ready?).to be_truthy
    end
    it 'check self_issued award' do
      expect(award.self_issued?).to be_truthy
      expect(award1.self_issued?).to be_falsey
    end

    it 'check discord award' do
      expect(award.discord?).to be_falsey
      expect(award1.discord?).to be_falsey
      award1.update channel_id: project.channels.last.id
      expect(award1.reload.discord?).to be_truthy
    end

    it 'round total_amount' do
      award.amount = 2.2
      award.save
      expect(award.reload.total_amount).to eq 0.22e1
    end

    it 'return recipient_auth_team' do
      auth_team = account1.authentication_teams.last
      award1.channel = project.channels.last
      award1.save
      expect(award.recipient_auth_team).to be_nil
      expect(award1.recipient_auth_team).to eq auth_team
    end

    it 'send send_confirm_email' do
      award.update email: 'reciver@test.st'
      expect { award.send_confirm_email }.to change { ActionMailer::Base.deliveries.count }.by(1)
      award.update confirm_token: '1234'
      expect { award.send_confirm_email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'confirm award' do
      award.update email: 'reciver@test.st', confirm_token: '1234'
      award.confirm!(account1)
      award.reload
      expect(award.account).to eq account1
      expect(award.confirmed?).to eq true
    end
  end

  describe '#send_award_notifications' do
    let!(:team) { create :team }
    let!(:account) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:discord_team) { create :team, provider: 'discord' }
    let!(:project) { create :project, account: account, token: create(:token, coin_type: 'erc20') }
    let!(:award_type) { create :award_type, project: project }
    let!(:channel) { create :channel, team: team, project: project, channel_id: 'channel_id', name: 'channel_id' }
    let!(:account1) { create :account }
    let!(:authentication1) { create :authentication, account: account1 }
    let!(:award) { create :award, award_type: award_type, issuer: account, channel: channel, account: account1 }

    let!(:message) { AwardMessage.call(award: award).notifications_message }

    before do
      team.build_authentication_team authentication
    end

    it 'sends a Slack notification' do
      # allow(award.slack_client).to receive(:send_award_notifications)
      message = AwardMessage.call(award: award).notifications_message
      token = authentication1.token
      stub_request(:post, 'https://slack.com/api/chat.postMessage').with(body: hash_including(text: message,
                                                                                              token: token,
                                                                                              channel: "##{channel.name}",
                                                                                              username: / Bot/,
                                                                                              icon_url: Comakery::Slack::AVATAR,
                                                                                              as_user: 'false',
                                                                                              link_names: '1')).to_return(body: {
                                                                                                ok: true,
                                                                                                channel: 'channel id',
                                                                                                message: { ts: 'this is a timestamp' }
                                                                                              }.to_json)
      stub_request(:post, 'https://slack.com/api/reactions.add').with(body: hash_including(channel: 'channel id',
                                                                                           timestamp: 'this is a timestamp',
                                                                                           name: 'thumbsup')).to_return(body: { ok: true }.to_json)
      award.send_award_notifications
    end

    it 'sends a Discord notification' do
      stub_discord_channels
      channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'discord_channel')
      award = create :award, award_type: award_type, amount: 3, issuer: account, channel: channel
      allow(award.discord_client).to receive(:send_message)
      award.send_award_notifications
      expect(award.discord_client).to have_received(:send_message)
    end
  end

  describe '.can_be_edited?' do
    let!(:award) { create(:award) }
    let!(:award_ready) { create(:award_ready) }
    let!(:award_cloned) { create(:award_ready, cloned_on_assignment_from_id: award.id) }
    let!(:award_cloneable) { create(:award_ready, number_of_assignments: 2) }

    before do
      award_cloneable.clone_on_assignment
    end

    it 'returns true for ready task when its not cloned or has clones' do
      expect(award_ready.can_be_edited?).to be_truthy
    end

    it 'returns false if task in non-ready state' do
      expect(award.can_be_edited?).to be_falsey
    end

    it 'returns false if task cloned' do
      expect(award_cloned.can_be_edited?).to be_falsey
    end

    it 'returns false if task has clones' do
      expect(award_cloneable.can_be_edited?).to be_falsey
    end
  end

  describe '.can_be_assigned?' do
    it 'returns true if award is ready or unpublished' do
      described_class.statuses.each_key do |status|
        award = create(:award, status: status)

        if status.in? %w[ready unpublished]
          expect(award.can_be_assigned?).to be_truthy
        else
          expect(award.can_be_assigned?).to be_falsey
        end
      end
    end
  end

  describe '.cloned?' do
    let!(:award) { create(:award_ready) }
    let!(:award_cloned) { create(:award_ready, cloned_on_assignment_from_id: award.id) }

    it 'returns true if task has a reference to another one' do
      expect(award_cloned.cloned?).to be_truthy
    end

    it 'returns false if task doesnt have a reference to another one' do
      expect(award.cloned?).to be_falsey
    end
  end

  describe '.any_clones?' do
    let!(:award_cloneable) { create(:award_ready, number_of_assignments: 2) }
    let!(:award) { create(:award_ready) }

    before do
      award_cloneable.clone_on_assignment
    end

    it 'returns true if task has referenced assignments' do
      expect(award_cloneable.any_clones?).to be_truthy
    end

    it 'returns false if task doesnt have referenced assignments' do
      expect(award.any_clones?).to be_falsey
    end
  end

  describe '.cloneable?' do
    let!(:award_cloneable) { create(:award_ready, number_of_assignments: 2) }
    let!(:award) { create(:award_ready) }

    it 'returns true if task has number_of_assignments greater than 1' do
      expect(award_cloneable.cloneable?).to be_truthy
    end

    it 'returns false if task has default number_of_assignments' do
      expect(award.cloneable?).to be_falsey
    end
  end

  describe '.should_be_cloned?' do
    let!(:award_should_be_cloned) { create(:award_ready, number_of_assignments: 10) }
    let!(:award_has_been_cloned_already) { create(:award_ready, number_of_assignments: 2) }
    let!(:award_shouldnt_be_cloned_at_all) { create(:award_ready) }

    before do
      award_has_been_cloned_already.clone_on_assignment
    end

    it 'returns true if current number of assignments plus one currently creating less than number_of_assignments allowed' do
      expect(award_should_be_cloned.should_be_cloned?).to be_truthy
    end

    it 'returns false if current number of assignments plus one currently creating equal or greater than number_of_assignments allowed' do
      expect(award_shouldnt_be_cloned_at_all.should_be_cloned?).to be_falsey
      expect(award_has_been_cloned_already.should_be_cloned?).to be_falsey
    end
  end

  describe '.can_be_cloned_for?(account)' do
    let(:award_ready) { create(:award_ready) }
    let(:award_account_started_max) { create(:award_ready) }
    let(:award_account_cloned_max) { create(:award_ready, number_of_assignments: 10, number_of_assignments_per_user: 2) }

    it 'returns true if account hasnt too many started tasks and hasnt reached maximum assignments' do
      expect(award_ready.can_be_cloned_for?(award_ready.account)).to be_truthy
    end

    it 'returns false if account has too many started tasks' do
      Award::STARTED_TASKS_PER_CONTRIBUTOR.times { create(:award, status: 'started', account: award_account_started_max.account) }
      expect(award_account_started_max.can_be_cloned_for?(award_account_started_max.account)).to be_falsey
    end

    it 'returns false if account reached maximum assignments' do
      2.times { award_account_cloned_max.clone_on_assignment.update!(account: award_account_cloned_max.account) }
      expect(award_account_cloned_max.can_be_cloned_for?(award_account_cloned_max.account)).to be_falsey
    end
  end

  describe '.reached_maximum_assignments_for?(account)' do
    let!(:award) { create(:award_ready, number_of_assignments: 10, number_of_assignments_per_user: 2) }
    let!(:account) { create(:account) }
    let!(:account_reached_max) { create(:account) }

    before do
      2.times { award.clone_on_assignment.update!(account: account_reached_max) }
    end

    it 'returns true if amount of assignments for this task from the user is greater or equal to allowed number_of_assignments_per_user' do
      expect(award.reached_maximum_assignments_for?(account_reached_max)).to be_truthy
    end

    it 'returns false if amount of assignments for this task from the user is less than allowed number_of_assignments_per_user' do
      expect(award.reached_maximum_assignments_for?(account)).to be_falsey
    end
  end

  describe '.clone_on_assignment' do
    let!(:award) { create(:award_ready) }

    it 'returns a new task duped from current one with correct releationships' do
      new_award = award.clone_on_assignment
      expect(new_award).not_to eq(award)
      expect(new_award.name).to eq(award.name)
      expect(new_award.cloned_on_assignment_from_id).to eq(award.id)
      expect(new_award.number_of_assignments).to eq(1)
    end
  end

  describe '.possible_quantity' do
    let!(:award_ready) { create(:award_ready) }
    let!(:award_ready_cloneable_2_times) { create(:award_ready, number_of_assignments: 2) }
    let!(:award_template) { create(:award_ready, number_of_assignments: 10) }
    let!(:award_cancelled) { create(:award, status: :cancelled) }
    let!(:award_rejected) { create(:award, status: :rejected) }

    it 'returns possible number_of_assignments' do
      expect(award_ready.possible_quantity).to eq(1)
      expect(award_ready_cloneable_2_times.possible_quantity).to eq(2)
    end

    it 'returns possible number_of_assignments minus current number of assignments for template tasks' do
      expect(award_template.possible_quantity).to eq(10)
      award_template.clone_on_assignment
      expect(award_template.reload.possible_quantity).to eq(9)
    end

    it 'returns zero for cancelled or rejected tasks' do
      expect(award_cancelled.possible_quantity).to eq(0)
      expect(award_rejected.possible_quantity).to eq(0)
    end
  end

  describe '.possible_total_amount' do
    let!(:award_ready) { create(:award_ready, amount: 1) }
    let!(:award_ready_cloneable_2_times) { create(:award_ready, amount: 1, number_of_assignments: 2) }
    let!(:award_template) { create(:award_ready, amount: 1, number_of_assignments: 10) }
    let!(:award_cancelled) { create(:award, amount: 1, status: :cancelled) }
    let!(:award_rejected) { create(:award, amount: 1, status: :rejected) }

    it 'returns total_amount multiplied by possible number_of_assignments' do
      expect(award_ready.possible_total_amount).to eq(1)
      expect(award_ready_cloneable_2_times.possible_total_amount).to eq(2)
    end

    it 'returns total_amount multiplied by possible number_of_assignments minus current number of assignments for template tasks' do
      award_template.clone_on_assignment
      expect(award_template.possible_total_amount).to eq(9)
    end

    it 'returns zero for cancelled or rejected tasks' do
      expect(award_cancelled.possible_total_amount).to eq(0)
      expect(award_rejected.possible_total_amount).to eq(0)
    end
  end

  describe 'expire!' do
    let!(:award_started) { create(:award, status: :started) }
    let!(:cloned_award) { create(:award).clone_on_assignment }

    it 'moves task back to ready state' do
      award_started.expire!
      award_started.reload
      expect(award_started.ready?).to be_truthy
      expect(award_started.expires_at.nil?).to be_truthy
      expect(award_started.account.nil?).to be_truthy
    end

    it 'cancelles cloned task' do
      cloned_award.expire!
      cloned_award.reload
      expect(cloned_award.cancelled?).to be_truthy
    end
  end

  describe 'expiring_notification_sent' do
    let!(:award_started) { create(:award, status: :started) }

    it 'clears notify_on_expiration_at value' do
      award_started.expiring_notification_sent
      award_started.reload
      expect(award_started.notify_on_expiration_at.nil?).to be_truthy
    end
  end

  describe 'run_expiration' do
    let!(:award) { create(:award, status: :started) }

    before do
      award.update(expires_at: 1.day.ago)
      award.run_expiration
    end

    it 'expires task if it should be expired' do
      expect(award.ready?).to be_truthy
    end
  end

  describe 'run_expiring_notification' do
    let!(:award) { create(:award, status: :started) }

    before do
      award.update(notify_on_expiration_at: 1.day.ago)
      award.run_expiring_notification
    end

    it 'notifies about expiration if it should be notified' do
      expect(award.started?).to be_truthy
      expect(award.notify_on_expiration_at.nil?).to be_truthy
    end
  end
end
