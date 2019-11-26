require 'rails_helper'

describe Project do
  describe 'associations' do
    let!(:project) { create :project }
    let!(:account) { create :account }

    before do
      project.admins << account
    end

    it 'has and belongs to many admins' do
      expect(project.admins).to match_array([account])
    end
  end

  describe 'validations' do
    it 'requires attributes' do
      expect(described_class.new(payment_type: 'project_token').tap(&:valid?).errors.full_messages.sort)
        .to eq(["Description can't be blank",
                "Account can't be blank",
                "Title can't be blank",
                "Legal project owner can't be blank",
                "Long identifier can't be blank"].sort)
    end

    describe 'payment types' do
      let(:project) { build :project }

      it 'for project token projects' do
        project.payment_type = 'project_token'
        expect(project).to be_valid
      end
    end

    describe 'payment_type' do
      let(:project) { create :project }

      it 'defaults to project_token' do
        expect(project.payment_type).to eq('project_token')
      end
    end

    describe 'maximum_tokens' do
      it 'accepts empty, zero or positive value' do
        project = create(:project)
        project.maximum_tokens = nil
        expect(project).to be_valid

        project.maximum_tokens = 0
        expect(project).to be_valid

        project.maximum_tokens = 100
        expect(project).to be_valid
      end

      it 'rejects negative value' do
        project = create(:project)
        project.maximum_tokens = -1
        expect(project).not_to be_valid
      end

      it 'can be modified if the record has been saved' do
        project = create(:project)
        project.maximum_tokens += 10
        expect(project).to be_valid
        project.maximum_tokens -= 5
        expect(project).to be_valid
      end
    end

    describe 'token' do
      it 'can be changed if project has no completed awards' do
        token1 = create(:token)
        token2 = create(:token)
        project = create(:project, token: token1)
        create(:award_ready, award_type: create(:award_type, project: project))
        project.update(token: token2)
        expect(project).to be_valid
        expect(project.token).to eq token2
      end

      it 'cannot be changed if project has completed awards' do
        token1 = create(:token)
        token2 = create(:token)
        project = create(:project, token: token1)
        create(:award, award_type: create(:award_type, project: project))
        project.update(token: token2)
        expect(project).not_to be_valid
        expect(project.errors.full_messages.first).to include 'cannot be changed if project has completed tasks'
      end

      it 'can be changed if it was not present and project has completed awards' do
        token1 = create(:token)
        token2 = create(:token)
        project = create(:project)
        project.update(token: nil)
        create(:award, award_type: create(:award_type, project: project))
        project.update(token: token2)
        expect(project).to be_valid
        expect(project.token).to eq token2
      end
    end

    describe 'terms_should_be_readonly' do
      let(:project_w_started_tasks) { create :project }
      let(:project_wo_started_tasks) { create :project }

      before do
        create(:award, status: :started, award_type: create(:award_type, project: project_w_started_tasks))
      end

      it 'doesnt allow to change terms fields when project has started tasks' do
        project_w_started_tasks.legal_project_owner = 'change'
        expect(project_w_started_tasks).not_to be_valid
        expect(project_w_started_tasks.errors[:base].first).to eq 'terms cannot be changed'
      end

      it 'allows to change terms fields when project hasnt any started tasks' do
        project_wo_started_tasks.legal_project_owner = 'change'
        project_wo_started_tasks.exclusive_contributions = false
        project_wo_started_tasks.confidentiality = false
        expect(project_wo_started_tasks).to be_valid
      end
    end

    it 'video_url is valid if video_url is a valid, absolute url, the domain is youtube.com or vimeo, and there is the identifier inside' do
      expect(build(:sb_project, video_url: 'https://youtube.com/watch?v=Dn3ZMhmmzK0')).to be_valid
      expect(build(:sb_project, video_url: 'https://youtube.com/embed/Dn3ZMhmmzK0')).to be_valid
      expect(build(:sb_project, video_url: 'https://youtu.be/jJrzIdDUfT4')).to be_valid
      expect(build(:sb_project, video_url: 'https://vimeo.com/314309860')).to be_valid

      expect(build(:sb_project, video_url: 'https://youtube.com/embed/')).not_to be_valid
      expect(build(:sb_project, video_url: 'https://youtu.be/')).not_to be_valid
      expect(build(:sb_project, video_url: 'https://youtu.be/').tap(&:valid?).errors.full_messages).to eq(['Video url must be a link to Youtube or Vimeo video'])
    end

    %w[video_url tracker contributor_agreement_url].each do |method|
      describe method do
        let(:project) { build :project }

        it 'is valid if tracker is a valid, absolute url' do
          project.tracker = 'https://youtu.be/jJrzIdDUfT4'
          expect(project).to be_valid
          expect(project.tracker).to eq('https://youtu.be/jJrzIdDUfT4')
        end

        it "doesn't allow completely wrong urls that cause parsing errors" do
          project.send("#{method}=", 'ゆアルエル')
          expect(project).not_to be_valid
          expect(project.errors.full_messages.first).to include 'must be a valid url'
        end

        it 'requires the url be valid if present' do
          project.send("#{method}=", 'foo')
          expect(project).not_to be_valid
          expect(project.errors.full_messages.first).to include('must be a valid url')
        end

        it 'is valid with no url specified' do
          project.send("#{method}=", nil)
          expect(project).to be_valid
        end

        it 'is valid if url is blank' do
          project.send("#{method}=", '')
          expect(project).to be_valid
        end
      end
    end
  end

  describe 'hooks' do
    describe 'udpate_awards_if_token_was_added' do
      let!(:task_w_no_token) { create(:award, status: 'ready') }

      before do
        task_w_no_token.project.update(token: nil)
        task_w_no_token.update(status: 'paid')
        task_w_no_token.project.update(token: create(:token))
      end

      it 'sets paid tasks status to accepted if token was added to the project' do
        expect(task_w_no_token.reload.accepted?).to be true
      end
    end

    describe 'store_license_hash' do
      let!(:project) { create(:project) }
      let!(:project_finalized) { create(:project) }

      before do
        create(:award, award_type: create(:award_type, project: project_finalized))
        project_finalized.update(agreed_to_license_hash: 'test')
      end

      it 'stores the hash of the latest CP license' do
        project.save
        expect(project.reload.agreed_to_license_hash).to eq(Digest::SHA256.hexdigest(File.read(Dir.glob(Rails.root.join('lib', 'assets', 'contribution_licenses', 'CP-*.md')).max_by { |f| File.mtime(f) })))
      end

      it 'doesnt update the hash if the terms are finalized' do
        project_finalized.save
        expect(project_finalized.reload.agreed_to_license_hash).to eq('test')
      end
    end

    describe 'set_whitelabel' do
      let!(:whitelabel_mission) { create(:mission, whitelabel: true) }
      let!(:whitelabel_project) { create(:project, mission: whitelabel_mission) }
      let!(:project) { create(:project) }

      it 'sets whitelabel value based on mission' do
        expect(whitelabel_project.whitelabel).to be_truthy
        expect(project.whitelabel).to be_falsey
      end
    end

    describe 'add_owner_as_interested' do
      let(:project) { create(:project) }

      it 'adds project owner as interested' do
        expect(project.interested).to include(project.account)
      end
    end
  end

  describe 'scopes' do
    describe '#community_award_types' do
      it 'returns all award types with community_awardable? == true' do
        project = create(:project)
        community_award_type = create(:award_type, project: project, community_awardable: true)
        normal_award_type = create(:award_type, project: project, community_awardable: false)

        expect(project.community_award_types).to eq([community_award_type])
      end
    end
  end

  describe '#total_awarded' do
    describe 'without project awards' do
      let(:project) { create :project }

      specify { expect(project.total_awarded).to eq(0) }
    end

    describe 'with project awards' do
      let!(:project1) { create :project }
      let!(:project1_award_type) { (create :award_type, project: project1) }
      let(:project2) { create :project }
      let!(:project2_award_type) { (create :award_type, project: project2) }
      let(:issuer) { create :account }
      let(:account) { create :account }

      before do
        create(:award, award_type: project1_award_type, quantity: 5, amount: 3, issuer: account, account: account)
        create(:award, award_type: project1_award_type, quantity: 5, amount: 3, issuer: account, account: account)

        create(:award, award_type: project2_award_type, quantity: 3, amount: 5, issuer: account, account: account)
        create(:award, award_type: project2_award_type, quantity: 7, amount: 5, issuer: account, account: account)
      end

      it 'returns the total amount of awards issued for the project' do
        expect(project1.total_awarded).to eq(30)
        expect(project2.total_awarded).to eq(50)
      end
    end
  end

  describe '#show_id' do
    let(:project) { create :project, long_id: '12345' }

    it 'show id for listed project' do
      expect(project.show_id).to eq(project.id)
    end

    it 'show long id for unlisted project' do
      project.public_unlisted!
      expect(project.show_id).to eq('12345')
    end
  end

  it 'total_month_awarded' do
    project = create :project
    award_type = create :award_type, project: project
    award_type2 = create :award_type, project: project
    award = create :award, award_type: award_type, amount: 10
    create :award, award_type: award_type2, amount: 20
    expect(project.total_month_awarded).to eq 30
    award.update created_at: DateTime.current - 35.days
    expect(project.total_month_awarded).to eq 20
  end

  it 'check invalid channel' do
    project = create :project
    attributes = {}
    expect(project.invalid_channel(attributes)).to eq true
    attributes['channel_id'] = 'general'
    attributes['team_id'] = 1
    expect(project.invalid_channel(attributes)).to eq false
  end

  describe '#top_contributors' do
    let!(:account) { create :account }
    let!(:account1) { create :account }
    let!(:project) { create :project }
    let!(:award_type) { create :award_type, project: project }
    let!(:award_type1) { create :award_type, project: project }
    let!(:other_award_type) { create :award_type }

    before do
      create :award, award_type: award_type, amount: 10, account: account
      create :award, award_type: award_type1, amount: 20, account: account1
    end
    it 'return project contributors sort by total amount' do
      expect(project.top_contributors.map(&:id)).to eq [account1.id, account.id]
    end
    it 'does not count other project award' do
      create :award, award_type: other_award_type, amount: 15, account: account
      expect(project.top_contributors.map(&:id)).to eq [account1.id, account.id]
    end
    it 'sort by newest if have same total_amount' do
      create :award, award_type: award_type, account: account, created_at: Time.zone.now + 2.seconds
      expect(project.top_contributors.map(&:id)).to eq [account.id, account1.id]
    end
    it 'Only return 5 top countributors' do
      10.times do
        create :award, award_type: award_type
      end
      expect(project.top_contributors.count).to eq 5
    end
  end

  describe '#awards_for_chart' do
    let!(:account) { create :account }
    let!(:project) { create :project }
    let!(:award_type) { create :award_type, project: project }

    before do
      8.times { create :award, award_type: award_type, amount: 10, account: account, created_at: 2.days.ago }
      1.times { create :award, award_type: award_type, amount: 10, account: account, created_at: 3.days.ago }
      3.times { create :award, award_type: award_type, amount: 10, account: account, created_at: 4.days.ago }
    end

    it 'limit number of days by requested number of latest awards' do
      expect(project.awards_for_chart(max: 10).size).to eq 2
    end
    it 'skip oldest (likely incomplete) day when number of days gets limited' do
      expect(project.awards_for_chart(max: 10).any? { |i| i[:date] == 3.days.ago.strftime('%Y-%m-%d') }).to be_truthy
      expect(project.awards_for_chart(max: 10).any? { |i| i[:date] == 4.days.ago.strftime('%Y-%m-%d') }).to be_falsey
    end
  end

  describe '#ready_tasks_by_specialty' do
    let!(:project) { create :project }
    let!(:specialty1) { create :specialty }
    let!(:specialty2) { create :specialty }
    let!(:award_type) { create :award_type, project: project }

    before do
      2.times { create :award_ready, specialty: specialty1, award_type: award_type }
      2.times { create :award_ready, specialty: specialty2, award_type: award_type }
    end

    it 'returns project tasks in ready state grouped by specialty' do
      expect(project.ready_tasks_by_specialty.size).to eq(2)
      expect(project.ready_tasks_by_specialty[specialty1]).to match_array(project.awards.ready.where(specialty: specialty1).to_a)
      expect(project.ready_tasks_by_specialty[specialty2]).to match_array(project.awards.ready.where(specialty: specialty2).to_a)
    end

    it 'limits amount of tasks per specialty' do
      expect(project.ready_tasks_by_specialty(1)[specialty1].size).to eq(1)
      expect(project.ready_tasks_by_specialty(1)[specialty2].size).to eq(1)
    end
  end

  describe '#stats' do
    it 'returns number of published batches' do
      project = create(:project)
      create(:award_type, project: project)
      create(:award_type, state: :draft, project: project)

      expect(project.stats[:batches]).to eq(1)
    end

    it 'returns number of tasks in progress' do
      project = create(:project)
      create(:award_ready, award_type: create(:award_type, project: project))
      create(:award, status: :paid, award_type: create(:award_type, project: project))

      expect(project.stats[:tasks]).to eq(1)
    end

    it 'returns number of accounts which have interest, started a task or created this project' do
      project = create(:project)
      create(:award, award_type: create(:award_type, project: project))
      create(:interest, project: project)

      expect(project.reload.stats[:interests]).to eq(3)
    end
  end

  describe 'default_award_type' do
    let(:project_w_default_award_type) { create :project }
    let(:project_wo_default_award_type) { create :project }

    before do
      project_w_default_award_type.award_types.create(name: 'Transfers', goal: '—', description: '—')
      project_w_default_award_type.reload
    end

    it 'creates default award type for project and returns it' do
      expect(project_wo_default_award_type.default_award_type).to be_instance_of(AwardType)
    end

    it 'returns default award type if its already present' do
      expect(project_w_default_award_type.default_award_type).to be_instance_of(AwardType)
    end
  end

  describe 'supports_transfer_rules?' do
    let(:project) { create :project }
    let(:project_w_comakery_token) { create :project, token: create(:token, coin_type: :comakery) }

    it 'returns true for projects with comakery token' do
      expect(project_w_comakery_token.supports_transfer_rules?).to be_truthy
    end

    it 'returns false for projects without comakery token' do
      expect(project.supports_transfer_rules?).to be_falsey
    end
  end
end
