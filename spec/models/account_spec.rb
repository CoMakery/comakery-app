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

    it 'requires #qtum_wallet to be a valid qtum address' do
      expect(account.qtum_wallet).to be_blank
      expect(account).to be_valid

      expect(account.tap { |a| a.update(qtum_wallet: 'foo') }.errors.full_messages).to eq(["Qtum wallet should start with 'Q', followed by 33 characters"])
      expect(account.tap { |a| a.update(qtum_wallet: '0x') }.errors.full_messages).to eq(["Qtum wallet should start with 'Q', followed by 33 characters"])
      expect(account.tap { |a| a.update(qtum_wallet: "Q#{'a' * 32}") }.errors.full_messages).to eq(["Qtum wallet should start with 'Q', followed by 33 characters"])
      expect(account.tap { |a| a.update(qtum_wallet: "Q#{'a' * 34}") }.errors.full_messages).to eq(["Qtum wallet should start with 'Q', followed by 33 characters"])
      expect(account.tap { |a| a.update(qtum_wallet: "0x#{'g' * 32}") }.errors.full_messages).to eq(["Qtum wallet should start with 'Q', followed by 33 characters"])

      expect(account.tap { |a| a.update(qtum_wallet: "q#{'a' * 33}") }).to be_valid
      expect(account.tap { |a| a.update(qtum_wallet: "Q#{'m' * 33}") }).to be_valid
    end

    it 'requires #cardano_wallet to be a valid cardano address' do
      expect(account.cardano_wallet).to be_blank
      expect(account).to be_valid
      error_message = "Cardano wallet should start with 'A', followed by 58 characters; or should start with 'D', followed by 103 characters"

      expect(account.tap { |a| a.update(cardano_wallet: 'foo') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(cardano_wallet: '0x') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(cardano_wallet: "Q#{'a' * 32}") }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(cardano_wallet: '37btjrVyb4KFNB81QswXHLkY39qp9WKocRpSuHk6BJJFewbS6hJxabQiMJyr7iAhb9wFKZH4U2vEbCfGpEW5TbpYwspeREeyfJSj3JqVF8sQRudC6q') }).to be_valid
    end

    it 'requires #bitcoin_wallet to be a valid bitcoin address' do
      expect(account.bitcoin_wallet).to be_blank
      expect(account).to be_valid
      error_message = 'Bitcoin wallet should start with either 1 or 3, make sure the length is between 26 and 35 characters'

      expect(account.tap { |a| a.update(bitcoin_wallet: 'foo') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(bitcoin_wallet: '0x') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(bitcoin_wallet: "Q#{'a' * 32}") }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(bitcoin_wallet: '2N3g7srauQ8HYCEXrTMiMkm43Hx9pSopmHU') }).to be_valid
    end

    it 'requires #eos_wallet to be a valid EOS account name' do
      expect(account.eos_wallet).to be_blank
      expect(account).to be_valid
      error_message = 'Eos wallet a-z,1-5 are allowed only, the length is 12 characters'

      expect(account.tap { |a| a.update(eos_wallet: 'foo') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(eos_wallet: '0x') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(eos_wallet: "Q#{'a' * 32}") }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(eos_wallet: ('a' * 12).to_s) }).to be_valid
    end

    it 'requires #tezos_wallet to be a valid tezos address' do
      expect(account.tezos_wallet).to be_blank
      expect(account).to be_valid
      error_message = "Tezos wallet should start with 'tz1', followed by 33 characters"

      expect(account.tap { |a| a.update(tezos_wallet: 'foo') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(tezos_wallet: '0x') }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(tezos_wallet: "tz1#{'a' * 32}") }.errors.full_messages).to eq([error_message])
      expect(account.tap { |a| a.update(tezos_wallet: 'tz1Zbe9hjjSnJN2U51E5W5fyRDqPCqWMCFN9') }).to be_valid
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

  describe 'authorize using password' do
    it 'does not accept invalid password' do
      expect(subject.authenticate('notright')).to be false
    end
    it 'returns account for valid password' do
      expect(subject.authenticate('12345678')).to eq subject
    end
  end

  describe 'associations' do
    let(:account) { create(:account) }
    let(:project) { create(:project, account: account) }
    let(:award_type) { create(:award_type, project: project) }
    let(:award) { create(:award, award_type: award_type, issuer: account) }
    let(:team) { create :team }
    let(:teammate) { create :account }
    let(:authentication) { create :authentication, account: account }
    let(:authentication_teammate) { create :authentication, account: teammate }
    let(:teammate_project) { create(:project, account: teammate) }
    let(:teammate_award_type) { create(:award_type, project: teammate_project) }
    let(:teammate_award) { create(:award, award_type: teammate_award_type, issuer: teammate) }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team authentication_teammate
      create(:channel, team: team, project: teammate_project, channel_id: 'general')
    end

    it 'has many projects' do
      expect(account.projects).to match_array([project])
    end

    it 'has many team projects' do
      expect(account.team_projects).to match_array([teammate_project])
    end

    it 'has many team awards' do
      expect(account.team_awards).to match_array([teammate_award])
    end

    it 'has many issued awards' do
      expect(account.issued_awards).to match_array([award])
    end

    it 'has many award types' do
      expect(account.award_types).to match_array([award_type])
    end

    it 'has many team award types' do
      expect(account.team_award_types).to match_array([teammate_award_type])
    end
  end

  describe '.accessable_award_types' do
    let!(:account) { create(:account) }
    let!(:project) { create(:project, account: account) }
    let!(:award_type) { create(:award_type, project: project) }
    let!(:team) { create :team }
    let!(:teammate) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:authentication_teammate) { create :authentication, account: teammate }
    let!(:teammate_project) { create(:project, account: teammate) }
    let!(:teammate_award_type) { create(:award_type, project: teammate_project) }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team authentication_teammate
      create(:channel, team: team, project: teammate_project, channel_id: 'general')
    end

    it 'returns own award types' do
      expect(account.accessable_award_types).to include(award_type)
    end

    it 'returns team award types' do
      expect(account.accessable_award_types).to include(teammate_award_type)
    end

    it 'returns award types from accessable projects' do
      accessable_project = create(:project, visibility: 'public_listed')
      accessable_award_type = create(:award_type, project: accessable_project)

      expect(account.accessable_award_types).to include(accessable_award_type)
    end
  end

  describe '.accessable_awards' do
    let!(:account) { create(:account) }
    let!(:project) { create(:project, account: account) }
    let!(:award_type) { create(:award_type, project: project) }
    let!(:award) { create(:award, award_type: award_type, issuer: account) }
    let!(:received_award) { create(:award, award_type: award_type, account: account) }
    let!(:team) { create :team }
    let!(:teammate) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:authentication_teammate) { create :authentication, account: teammate }
    let!(:teammate_project) { create(:project, account: teammate) }
    let!(:teammate_award_type) { create(:award_type, project: teammate_project) }
    let!(:teammate_award) { create(:award, award_type: teammate_award_type, issuer: teammate) }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team authentication_teammate
      create(:channel, team: team, project: teammate_project, channel_id: 'general')

      Award::EXPERIENCE_LEVELS['Demonstrated Skills'].times do
        create(:award, account: account, specialty: account.specialty)
      end
    end

    it 'returns received awards' do
      expect(account.accessable_awards).to include(received_award)
    end

    it 'returns issued awards' do
      expect(account.accessable_awards).to include(award)
    end

    it 'returns team issued awards' do
      expect(account.accessable_awards).to include(teammate_award)
    end

    it 'returns awards from accessable award types with ready state and matching experience' do
      accessable_project = create(:project, visibility: 'public_listed')
      accessable_award_type = create(:award_type, project: accessable_project)
      award_w_matching_experience = create(:award_ready, specialty: account.specialty, award_type: accessable_award_type, experience_level: Award::EXPERIENCE_LEVELS['Demonstrated Skills'])
      award_w_not_matching_experience = create(:award_ready, specialty: account.specialty, award_type: accessable_award_type, experience_level: Award::EXPERIENCE_LEVELS['Established Contributor'])
      award_in_ready_state = create(:award_ready, specialty: account.specialty, award_type: accessable_award_type)
      award_in_non_ready_state = create(:award, specialty: account.specialty, award_type: accessable_award_type)

      expect(account.accessable_awards).to include(award_in_ready_state)
      expect(account.accessable_awards).not_to include(award_in_non_ready_state)
      expect(account.accessable_awards).to include(award_w_matching_experience)
      expect(account.accessable_awards).not_to include(award_w_not_matching_experience)
    end
  end

  describe '.awards_matching_experience' do
    let!(:account) { create(:account) }
    let!(:project) { create(:project, account: account) }
    let!(:award_type) { create(:award_type, project: project) }
    let!(:award) { create(:award, award_type: award_type, issuer: account) }
    let!(:received_award) { create(:award, award_type: award_type, account: account) }
    let!(:team) { create :team }
    let!(:teammate) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:authentication_teammate) { create :authentication, account: teammate }
    let!(:teammate_project) { create(:project, account: teammate) }
    let!(:teammate_award_type) { create(:award_type, project: teammate_project) }
    let!(:teammate_award) { create(:award, award_type: teammate_award_type, issuer: teammate) }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team authentication_teammate
      create(:channel, team: team, project: teammate_project, channel_id: 'general')

      Award::EXPERIENCE_LEVELS['Demonstrated Skills'].times do
        create(:award, account: account, specialty: account.specialty)
      end
    end

    it 'returns awards from accessable award types with ready state and matching experience' do
      accessable_project = create(:project, visibility: 'public_listed')
      accessable_award_type = create(:award_type, project: accessable_project)
      award_w_matching_experience = create(:award_ready, specialty: account.specialty, award_type: accessable_award_type, experience_level: Award::EXPERIENCE_LEVELS['Demonstrated Skills'])
      award_w_zero_experience = create(:award_ready, specialty: account.specialty, award_type: accessable_award_type)
      award_w_not_matching_experience = create(:award_ready, specialty: account.specialty, award_type: accessable_award_type, experience_level: Award::EXPERIENCE_LEVELS['Established Contributor'])
      award_w_matching_generic_experience = create(:award_ready, award_type: accessable_award_type, experience_level: Award::EXPERIENCE_LEVELS['Demonstrated Skills'])
      award_w_not_matching_generic_experience = create(:award_ready, award_type: accessable_award_type, experience_level: Award::EXPERIENCE_LEVELS['Established Contributor'])
      award_w_zero_generic_experience = create(:award_ready, award_type: accessable_award_type)
      award_in_non_ready_state = create(:award, specialty: account.specialty, award_type: accessable_award_type)

      expect(account.awards_matching_experience).to include(award_w_matching_experience)
      expect(account.awards_matching_experience).to include(award_w_zero_experience)
      expect(account.awards_matching_experience).to include(award_w_matching_generic_experience)
      expect(account.awards_matching_experience).to include(award_w_zero_generic_experience)
      expect(account.awards_matching_experience).not_to include(award_in_non_ready_state)
      expect(account.awards_matching_experience).not_to include(award_w_not_matching_generic_experience)
      expect(account.awards_matching_experience).not_to include(award_w_not_matching_experience)
    end
  end

  describe '.related_awards' do
    let!(:account) { create(:account) }
    let!(:project) { create(:project, account: account) }
    let!(:award_type) { create(:award_type, project: project) }
    let!(:award) { create(:award, award_type: award_type, issuer: account) }
    let!(:received_award) { create(:award, award_type: award_type, account: account) }
    let!(:team) { create :team }
    let!(:teammate) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:authentication_teammate) { create :authentication, account: teammate }
    let!(:teammate_project) { create(:project, account: teammate) }
    let!(:teammate_award_type) { create(:award_type, project: teammate_project) }
    let!(:teammate_award) { create(:award, award_type: teammate_award_type, issuer: teammate) }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team authentication_teammate
      create(:channel, team: team, project: teammate_project, channel_id: 'general')
    end

    it 'returns received awards' do
      expect(account.related_awards).to include(received_award)
    end

    it 'returns issued awards' do
      expect(account.related_awards).to include(award)
    end

    it 'returns team issued awards' do
      expect(account.related_awards).to include(teammate_award)
    end
  end

  describe '.experiences' do
    let(:account) { create(:account) }
    let(:other_specialty) { create(:specialty) }

    before do
      3.times { create(:award, specialty: account.specialty, account: account) }
      1.times { create(:award, specialty: other_specialty, account: account) }
    end

    it 'returns account experiences for all existing specialties' do
      expect(account.experiences[account.specialty.id]).to eq(3)
      expect(account.experiences[other_specialty.id]).to eq(1)
      expect(account.experiences[nil]).to eq(4)
      expect(account.experiences[0]).to eq(4)
    end
  end

  describe '.experience_for(specialty)' do
    let(:account) { create(:account) }

    before do
      3.times { create(:award, specialty: account.specialty, account: account) }
      1.times { create(:award, account: account) }
    end

    it 'returns number of completed awards for given specialty' do
      expect(account.experience_for(account.specialty)).to eq(3)
    end

    it 'returns total number of completed awards when no specialty specified' do
      expect(account.experience_for(nil)).to eq(4)
    end
  end

  describe '.total_experience' do
    let(:account) { create(:account) }

    before do
      2.times { create(:award, account: account) }
    end

    it 'returns total number of completed awards' do
      expect(account.total_experience).to eq(2)
    end
  end

  describe '.tasks_to_unlock(award)' do
    let(:account) { create(:account) }
    let(:award_with_higher_exp_level) { create(:award, experience_level: Award::EXPERIENCE_LEVELS['Demonstrated Skills']) }

    before do
      create(:award, award_type: award_with_higher_exp_level.award_type, account: account)
    end

    it 'returns number of tasks to be completed to achieve exp level suitable for a given award' do
      expect(account.tasks_to_unlock(award_with_higher_exp_level)).to eq(award_with_higher_exp_level.experience_level - account.experience_for(award_with_higher_exp_level.specialty))
    end
  end

  describe 'my projects' do
    let!(:team) { create :team }
    let!(:authentication) { create :authentication, account: account }
    let!(:account1) { create :account }
    let!(:authentication1) { create :authentication, account: account1 }
    let!(:project1) { create :project, account: account, visibility: 'member', title: 'my private project' }
    let!(:project2) { create :project, account: account, visibility: 'public_listed', title: 'my public project' }
    let!(:project3) { create :project, account: account, visibility: 'archived', title: 'archived project' }
    let!(:project4) { create :project, account: account, visibility: 'public_unlisted', title: 'unlisted project' }
    let!(:project5) { create :project, account: account1, visibility: 'member', title: 'member project' }
    let!(:project6) { create :project, visibility: 'member', title: 'other team project' }
    let!(:project7) { create :project, visibility: 'member', title: 'award project' }
    let!(:award_type) { create :award_type, project: project7 }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team authentication1
    end

    it 'accessable prọjects include my own project' do
      expect(account.accessable_projects.map(&:title)).to match_array ['my private project', 'my public project', 'archived project', 'unlisted project']
    end

    it 'accessable prọjects include other public project' do
      project6.public_listed!
      expect(account.accessable_projects.map(&:title)).to match_array ['my private project', 'my public project', 'archived project', 'unlisted project', 'other team project']
    end

    it 'accessable prọjects include team member project' do
      project5.channels.create(team: team, channel_id: 'general')
      expect(account.accessable_projects.map(&:title)).to match_array ['my private project', 'my public project', 'archived project', 'unlisted project', 'member project']
    end

    it 'accessable prọjects include awarded project' do
      create :award, award_type: award_type, account: account
      expect(account.accessable_projects.map(&:title)).to match_array ['my private project', 'my public project', 'archived project', 'unlisted project', 'award project']
    end

    it '#other_member_projects' do
      project5.channels.create(team: team, channel_id: 'general')
      expect(account.other_member_projects.map(&:title)).to match_array ['member project']
    end

    it '#other_member_projects including award projects' do
      create :award, award_type: award_type, account: account
      expect(account.other_member_projects.map(&:title)).to match_array ['award project']
    end
  end

  it 'confirm email' do
    account = create :account, email_confirm_token: '12345'
    expect(account.confirmed?).to be_falsey
    account.confirm!
    expect(account.reload.confirmed?).to be_truthy
  end

  it 'return array of award by project' do
    account = create :account
    project = create :project
    award_type = create :award_type, project: project, name: 'type 1'
    award_type1 = create :award_type, project: project, name: 'type 2'
    create :award, award_type: award_type, amount: 10, account: account
    create :award, award_type: award_type1, amount: 20, account: account
    expect(account.award_by_project(project)).to eq [{ name: 'type 2', total: 20 }, { name: 'type 1', total: 10 }]
  end
  describe 'team projects' do
    let!(:team) { create :team }
    let!(:account) { create :account }
    let!(:authentication) { create :authentication, account: account }
    let!(:team_account) { create :account }
    let!(:team_authentication) { create :authentication, account: team_account }
    let!(:project) { create :project, account: account }
    let!(:team_project) { create :project, account: team_account }

    before do
      team.build_authentication_team authentication
      team.build_authentication_team team_authentication
      create :channel, team: team, project: team_project, channel_id: 'general'
    end

    it 'return projects of same team members' do
      expect(account.other_member_projects.map(&:id)).to eq [team_project.id]
    end

    it 'check if a project in same team' do
      other_project = create :project
      expect(account.same_team_project?(project)).to be_falsey
      expect(account.same_team_project?(other_project)).to be_falsey
      expect(account.same_team_project?(team_project)).to be_truthy
    end
    it 'check if a project in same team or self owned' do
      other_project = create :project
      expect(account.same_team_or_owned_project?(project)).to be_truthy
      expect(account.same_team_or_owned_project?(other_project)).to be_falsey
      expect(account.same_team_or_owned_project?(team_project)).to be_truthy
    end
  end

  it 'send send_reset_password_request' do
    account.send_reset_password_request
    expect(account.reset_password_token).not_to be_nil
  end

  it 'set account to unconfirm it update email' do
    account.email = 'new@test.st'
    account.save
    expect(account.reload.confirmed?).to be_falsey
  end

  it '#downcase_email' do
    account.email = 'NEW@TEST.st'
    account.save
    expect(account.reload.email).to eq 'new@test.st'
  end

  it 'awards_csv' do
    award = create(:award, account: account)
    award = award.decorate
    expect(CSV.parse(account.awards_csv, col_sep: "\t", encoding: 'utf-16le')).to eq([["\uFEFFProject", 'Award Type', 'Total Amount', 'Issuer', 'Date'], ['Uber for Cats', 'Contribution', '50', award.issuer_display_name, award.created_at.strftime('%b %d, %Y')]].map { |row| row.map { |cell| cell.encode 'utf-16le' } })
  end
end
