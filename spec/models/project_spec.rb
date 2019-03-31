require 'rails_helper'

describe Project do
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

  describe 'scopes' do
    describe '.with_last_activity_at' do
      it 'returns projects ordered by when the most recent award created_at, then by project created_at' do
        p1_8 = create(:project, title: 'p1_8', created_at: 8.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 1.day.ago) } }
        p2_3 = create(:project, title: 'p2_3', created_at: 3.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 2.days.ago) } }
        p3_6 = create(:project, title: 'p3_6', created_at: 6.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }
        p3_5 = create(:project, title: 'p3_5', created_at: 5.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }
        p3_4 = create(:project, title: 'p3_4', created_at: 4.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }

        expect(described_class.count).to eq(5)
        expect(described_class.with_last_activity_at.all.map(&:title)).to eq(%w[p1_8 p2_3 p3_4 p3_5 p3_6])
      end

      it '.featured overrides last activity' do
        p1_8 = create(:project, title: 'p1_8', created_at: 8.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 1.day.ago) } }
        p2_3 = create(:project, title: 'p2_3', created_at: 3.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 2.days.ago) } }
        p3_6 = create(:project, title: 'p3_6', created_at: 6.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }
        p3_5 = create(:project, title: 'p3_5', created_at: 5.days.ago, featured: 1).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }
        p3_4 = create(:project, title: 'p3_4', created_at: 4.days.ago, featured: 0).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }

        expect(described_class.count).to eq(5)
        expect(described_class.featured.with_last_activity_at.all.map(&:title)).to eq(%w[p3_4 p3_5 p1_8 p2_3 p3_6])
      end
    end

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

  describe '#access_unlisted' do
    let(:team) { create :team }
    let(:account) { create :account }
    let(:auth) { create :authentication, account: account }
    let(:project) { create :project, account: account, long_id: '12345' }
    let(:same_team_account) { create :account }
    let(:auth1) { create :authentication, account: same_team_account }
    let(:other_team_account) { create :account }

    before do
      team.build_authentication_team auth
      team.build_authentication_team auth1
      project.channels.create(team: team, channel_id: '123')
    end

    it 'can acccess public unlisted project via long_id' do
      project.public_unlisted!
      expect(project.access_unlisted?(nil)).to be_truthy
    end

    it 'other team members can not access member_unlisted project' do
      project.member_unlisted!
      expect(project.access_unlisted?(other_team_account)).to be_falsey
    end

    it 'owner can access member_unlisted project' do
      project.member_unlisted!
      expect(project.access_unlisted?(account)).to be_truthy
    end

    it 'same team members can access member_unlisted project' do
      project.member_unlisted!
      expect(project.access_unlisted?(same_team_account)).to be_truthy
    end
  end

  describe '#can_be_access' do
    let(:team) { create :team }
    let(:account) { create :account }
    let(:auth) { create :authentication, account: account }
    let(:project) { create :project, account: account, long_id: '12345' }
    let(:same_team_account) { create :account }
    let(:auth1) { create :authentication, account: same_team_account }
    let(:other_team_account) { create :account }

    before do
      team.build_authentication_team auth
      team.build_authentication_team auth1
      project.channels.create(team: team, channel_id: '123')
    end

    it 'everyone can acccess public project' do
      project.public_listed!
      expect(project.can_be_access?(nil)).to be_truthy
    end

    it 'other team members can not access public project with require_confidentiality' do
      project.update require_confidentiality: true
      expect(project.can_be_access?(other_team_account)).to be_falsey
    end

    it 'owner can access project' do
      project.member!
      expect(project.can_be_access?(account)).to be_truthy
    end

    it 'same team members can access member_unlisted project' do
      project.member!
      expect(project.can_be_access?(same_team_account)).to be_truthy
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
end
