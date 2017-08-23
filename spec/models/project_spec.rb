require 'rails_helper'

describe Project do
  describe 'validations' do
    it 'requires attributes' do
      expect(described_class.new(payment_type: 'project_token').tap(&:valid?).errors.full_messages.sort)
        .to eq(["Description can't be blank",
                'Maximum tokens must be greater than 0',
                "Owner account can't be blank",
                "Slack channel can't be blank",
                "Slack team can't be blank",
                "Slack team image 132 url can't be blank",
                "Slack team image 34 url can't be blank",
                "Slack team name can't be blank",
                "Title can't be blank",
                "Legal project owner can't be blank"].sort)

      expect(described_class.new(slack_team_domain: '').tap(&:valid?).errors.full_messages).to be_include("Slack team domain can't be blank")
      expect(described_class.new(slack_team_domain: 'XX').tap(&:valid?).errors.full_messages).to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
      expect(described_class.new(slack_team_domain: '-xx').tap(&:valid?).errors.full_messages).to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
      expect(described_class.new(slack_team_domain: "good\n-bad").tap(&:valid?).errors.full_messages).to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')

      expect(described_class.new(slack_team_domain: '3-xx').tap(&:valid?).errors.full_messages).not_to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
      expect(described_class.new(slack_team_domain: 'a').tap(&:valid?).errors.full_messages).not_to be_include('Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number')
    end

    describe 'payment types' do
      let(:project) { build :project, royalty_percentage: nil, maximum_royalties_per_month: nil }

      it 'for USD projects' do
        project.payment_type = 'revenue_share'
        expect_royalty_fields_present
      end

      it 'for project token projects' do
        project.payment_type = 'project_token'
        expect(project).to be_valid
      end

      def expect_royalty_fields_present
        expect(project.tap(&:valid?).errors.full_messages.sort).to eq(["Royalty percentage can't be blank",
                                                                       "Maximum royalties per month can't be blank"].sort)
      end
    end

    describe 'denomination enumeration' do
      let(:project) { build :project }

      it 'default' do
        expect(described_class.new.denomination).to eq('USD')
      end

      specify do
        project.USD!
        expect(project.denomination).to eq('USD')
      end

      specify do
        project.BTC!
        expect(project.denomination).to eq('BTC')
      end

      specify do
        project.ETH!
        expect(project.denomination).to eq('ETH')
      end
    end

    describe 'denomination' do
      let(:project) { create :project, denomination: 'USD' }

      it 'can be changed' do
        project.denomination = 'BTC'

        expect(project).to be_valid
      end

      it 'cannot be changed after revenue is recorded' do
        create :revenue, project: project
        project.reload
        project.denomination = 'BTC'

        expect(project).to be_invalid
        expect(project.errors[:denomination]).to eq(['cannot be changed because revenue has been recorded'])
      end

      it 'does not block the project from being changed after revenue is recorded' do
        create :revenue, project: project
        project.reload
        project.title = 'new title'
        expect(project).to be_valid

        project.denomination = 'BTC'
        expect(project).not_to be_valid
      end

      it 'cannot be changed after the contract terms are finalized' do
        project.update(license_finalized: true)
        project.denomination = 'BTC'

        expect(project).to be_invalid
        expect(project.errors[:denomination]).to eq(['cannot be changed because the license terms are finalized'])
      end

      it 'can be changed at the same time the license terms are finalized' do
        project.denomination = 'BTC'
        project.license_finalized = true

        expect(project).to be_valid
      end
    end

    describe :royalty_percentage do
      it 'has high precision' do
        project = create :project, royalty_percentage: '99.' + '9' * 13
        project.reload
        expect(project.royalty_percentage).to eq(BigDecimal('99.999_999_999_999_9'))
      end

      xit 'is invalid if precision is exceeded' do
        project = create :project, royalty_percentage: '99.' + '9' * 14
        expect(project).to be_invalid
        expect(project.errors[:royalty_percentage]).to eq(['must have less than 13 decimal precision'])
      end

      it 'can represent 100%' do
        project = create :project, royalty_percentage: '100'
        project.reload
        expect(project.royalty_percentage).to eq(100.0)
      end

      it 'can be 0%' do
        project = create :project, royalty_percentage: 0
        project.reload
        expect(project).to be_valid
      end

      it "can't be greater than 100%" do
        project = build :project
        project.royalty_percentage = 100.1
        expect(project).not_to be_valid
        expect(project.errors[:royalty_percentage]).to eq(['must be less than or equal to 100'])
      end

      it "can't be < 0" do
        project = build :project
        project.royalty_percentage = -1
        expect(project).not_to be_valid
        expect(project.errors[:royalty_percentage]).to eq(['must be greater than or equal to 0'])
      end
    end

    describe 'payment_type' do
      let(:project) { create(:project) }
      let(:order) { %i[revenue_share project_token] }

      it 'defaults to revenue_share' do
        expect(project.payment_type).to eq('revenue_share')
      end

      it 'has the correct enum index values' do
        order.each_with_index do |item, index|
          expect(described_class.payment_types[item]).to eq index
        end
      end
    end

    describe 'maximum_tokens' do
      it 'prevents modification if the record has been saved' do
        project = create(:project)
        project.maximum_tokens += 10
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to be_include("Maximum tokens can't be changed")
      end
    end

    describe 'ethereum_enabled' do
      let(:project) { create(:project) }

      it { expect(project.ethereum_enabled).to eq(false) }

      it 'can be set to true' do
        project.ethereum_enabled = true
        project.save!
        project.reload
        expect(project.ethereum_enabled).to eq(true)
      end

      it 'if set to false can be set to false' do
        project.ethereum_enabled = false
        project.save!
        project.ethereum_enabled = false
        expect(project).to be_valid
      end

      it 'once set to true it cannot be set to false' do
        project.ethereum_enabled = true
        project.save!
        project.ethereum_enabled = false
        expect(project.tap(&:valid?).errors.full_messages.first)
          .to eq('Ethereum enabled cannot be set to false after it has been set to true')
      end
    end

    describe '#ethereum_contract_address' do
      let(:project) { create(:project) }
      let(:address) { '0x' + 'a' * 40 }

      it 'validates with a valid ethereum address' do
        expect(build(:project, ethereum_contract_address: nil)).to be_valid
        expect(build(:project, ethereum_contract_address: "0x#{'a' * 40}")).to be_valid
        expect(build(:project, ethereum_contract_address: "0x#{'A' * 40}")).to be_valid
      end

      it 'does not validate with an invalid ethereum address' do
        expected_error_message = "Ethereum contract address should start with '0x', followed by a 40 character ethereum address"
        expect(build(:project, ethereum_contract_address: 'foo').tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: '0x').tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x#{'a' * 39}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x#{'a' * 41}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x#{'g' * 40}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
      end

      it { expect(project.ethereum_contract_address).to eq(nil) }

      it 'can be set' do
        project.ethereum_contract_address = address
        project.save!
        project.reload
        expect(project.ethereum_contract_address).to eq(address)
      end

      it 'once set cannot be set unset' do
        project.ethereum_contract_address = address
        project.save!
        project.ethereum_contract_address = nil
        expect(project).not_to be_valid
        expect(project.errors.full_messages.to_sentence).to match \
          /Ethereum contract address cannot be changed after it has been set/
      end

      it 'once set it cannot be set to another value' do
        project.ethereum_contract_address = address
        project.save!
        project.ethereum_contract_address = '0x' + 'b' * 40
        expect(project).not_to be_valid
        expect(project.errors.full_messages.to_sentence).to match \
          /Ethereum contract address cannot be changed after it has been set/
      end
    end

    it 'video_url is valid if video_url is a valid, absolute url, the domain is youtube.com, and there is the identifier inside' do
      expect(build(:sb_project, video_url: 'https://youtube.com/watch?v=Dn3ZMhmmzK0')).to be_valid
      expect(build(:sb_project, video_url: 'https://youtube.com/embed/Dn3ZMhmmzK0')).to be_valid
      expect(build(:sb_project, video_url: 'https://youtu.be/jJrzIdDUfT4')).to be_valid

      expect(build(:sb_project, video_url: 'https://youtube.com/embed/')).not_to be_valid
      expect(build(:sb_project, video_url: 'https://youtu.be/')).not_to be_valid
      expect(build(:sb_project, video_url: 'https://youtu.be/').tap(&:valid?).errors.full_messages).to eq(["Video url must be a Youtube link like 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'"])
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

  describe 'associations' do
    it 'has many award_types and accepts them as nested attributes' do
      project = described_class.create!(description: 'foo',
                                        title: 'This is a title',
                                        owner_account: create(:account),
                                        slack_team_id: '123',
                                        slack_channel: 'slack_channel',
                                        slack_team_name: 'This is a slack team name',
                                        slack_team_image_34_url: 'http://foo.com/kittens-34.jpg',
                                        slack_team_image_132_url: 'http://foo.com/kittens-132.jpg',
                                        maximum_tokens: 10_000_000,
                                        legal_project_owner: 'legal project owner',
                                        payment_type: 'project_token',
                                        award_types_attributes: [
                                          { 'name' => 'Small award', 'amount' => '1000' },
                                          { 'name' => '', 'amount' => '1000' },
                                          { 'name' => 'Award', 'amount' => '' }
                                        ])

      expect(project.award_types.count).to eq(1)
      expect(project.award_types.first.name).to eq('Small award')
      expect(project.award_types.first.amount).to eq(1000)
      expect(project.slack_team_id).to eq('123')
      expect(project.slack_team_name).to eq('This is a slack team name')
      expect(project.slack_team_image_34_url).to eq('http://foo.com/kittens-34.jpg')
      expect(project.slack_team_image_132_url).to eq('http://foo.com/kittens-132.jpg')

      project.update(award_types_attributes: { id: project.award_types.first.id, _destroy: true })
      expect(project.award_types.count).to eq(0)
    end
  end

  it 'enum of denominations should contain the platform wide currencies' do
    project_denominations = described_class.denominations.map { |x, _| x }.sort
    platform_denominations = Comakery::Currency::DENOMINATIONS.keys.sort
    expect(project_denominations).to eq(platform_denominations)
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

      describe '#for_account #not_for_account' do
        it "returns all projects for the given account's slack auth" do
          account = create(:account).tap do |a|
            create(:authentication, account: a, slack_team_id: 'foo', updated_at: 1.day.ago)
            create(:authentication, account: a, slack_team_id: 'bar', updated_at: 2.days.ago)
          end
          account2 = create(:account).tap { |a| create(:authentication, account: a, slack_team_id: 'qux') }

          foo_project = create(:project, slack_team_id: 'foo', title: 'Foo')
          foo2_project = create(:project, slack_team_id: 'foo', title: 'Foo2')
          bar_project = create(:project, slack_team_id: 'bar', title: 'Bar')
          qux_project = create(:project, slack_team_id: 'qux', title: 'Qux')

          expect(described_class.for_account(account).pluck(:title)).to match_array(%w[Foo Foo2])
          expect(described_class.not_for_account(account).pluck(:title)).to match_array(%w[Bar Qux])
        end
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

  describe '#owner_slack_user_name' do
    let!(:owner) { create :account }
    let!(:project) { create :project, owner_account: owner, slack_team_id: 'reds' }

    it 'returns the user name' do
      create(:authentication, account: owner, slack_team_id: 'reds', slack_first_name: 'John', slack_last_name: 'Doe', slack_user_name: 'johnny')
      expect(project.owner_slack_user_name).to eq('John Doe')
    end

    it 'returns the user name for the correct auth, even if older' do
      travel_to Date.new(2015)
      create(:authentication, account: owner, slack_team_id: 'reds', slack_first_name: 'John', slack_last_name: 'Red', slack_user_name: 'johnny')
      travel_to Date.new(2016)
      create(:authentication, account: owner, slack_team_id: 'blues', slack_first_name: 'John', slack_last_name: 'Blue', slack_user_name: 'johnny')
      expect(project.owner_slack_user_name).to eq('John Red')
    end

    it "doesn't blow up if the isn't an auth" do
      expect(project.owner_slack_user_name).to be_nil
    end
  end

  describe '#transitioned_to_ethereum_enabled?' do
    it 'triggers if new project is saved with ethereum_enabled = true' do
      project = build(:project, ethereum_enabled: true)
      project.save!
      expect(project.transitioned_to_ethereum_enabled?).to eq(true)
    end

    it 'triggers if existing project is saved with ethereum_enabled = true' do
      project = create(:project, ethereum_enabled: false)
      project.update!(ethereum_enabled: true)
      expect(project.transitioned_to_ethereum_enabled?).to eq(true)
    end

    it 'does not trigger if new project is saved with ethereum_enabled = false' do
      project = build(:project, ethereum_enabled: false)
      project.save!
      expect(project.transitioned_to_ethereum_enabled?).to eq(false)
    end

    it 'is false if an existing project with an account is transitioned from ethereum_enabled = false to true' do
      project = create(:project, ethereum_enabled: false, ethereum_contract_address: '0x' + '7' * 40)
      project.update!(ethereum_enabled: true)
      expect(project.transitioned_to_ethereum_enabled?).to eq(false)
    end
  end

  describe '#total_awarded' do
    describe 'without project awards' do
      let(:project) { create :project }

      specify { expect(project.total_awarded).to eq(0) }
    end

    describe 'with project awards' do
      let!(:project1) { create :project }
      let!(:project1_award_type) { (create :award_type, project: project1, amount: 3) }
      let(:project2) { create :project }
      let!(:project2_award_type) { (create :award_type, project: project2, amount: 5) }
      let(:issuer) { create :account }
      let(:authentication) { create :authentication }

      before do
        project1_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
        project1_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)

        project2_award_type.awards.create_with_quantity(3, issuer: issuer, authentication: authentication)
        project2_award_type.awards.create_with_quantity(7, issuer: issuer, authentication: authentication)
      end

      it 'returns the total amount of awards issued for the project' do
        expect(project1.total_awarded).to eq(30)
        expect(project2.total_awarded).to eq(50)
      end
    end
  end

  describe '#total_revenue' do
    let(:project_without_revenue) { create :project }
    let(:project_with_revenue) { create :project }

    before do
      project_with_revenue.revenues.create(amount: 7, currency: 'USD', recorded_by: project_with_revenue.owner_account)
      project_with_revenue.revenues.create(amount: 11, currency: 'USD', recorded_by: project_with_revenue.owner_account)
    end

    specify { expect(project_without_revenue.total_revenue).to eq(0) }

    specify { expect(project_with_revenue.total_revenue).to eq(18) }
  end

  describe '#total_revenue_shared' do
    describe 'with revenue sharing awards' do
      let!(:project) { create :project, payment_type: :revenue_share }

      it 'with no revenue sharing percentage entered' do
        project.update(royalty_percentage: nil)
        expect(project.total_revenue_shared).to eq(0)
        expect(project.total_revenue_shared).to be_a(BigDecimal)
      end

      it 'with percentage and no revenue' do
        project.update(royalty_percentage: 10)

        expect(project.total_revenue_shared).to eq(0)
        expect(project.total_revenue_shared).to be_a(BigDecimal)
      end

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared).to eq(127)
        expect(project.total_revenue_shared).to be_a(BigDecimal)
      end
    end

    describe 'with project token awards' do
      let(:project) { create :project, payment_type: :project_token }

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared).to eq(0)
        expect(project.total_revenue_shared).to be_a(BigDecimal)
      end
    end
  end

  describe '#total_revenue_shared_unpaid' do
    describe 'with revenue sharing awards' do
      let!(:project) { create :project, payment_type: :revenue_share }
      let(:authentication) { create :authentication }
      let(:project_award_type) { create :award_type, project: project, amount: 1 }

      it 'with no revenue sharing percentage entered' do
        project.update(royalty_percentage: nil)
        expect(project.total_revenue_shared_unpaid).to eq(0)
        expect(project.total_revenue_shared_unpaid).to be_a(BigDecimal)
      end

      it 'with percentage and no revenue' do
        project.update(royalty_percentage: 10)

        expect(project.total_revenue_shared_unpaid).to eq(0)
        expect(project.total_revenue_shared_unpaid).to be_a(BigDecimal)
      end

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared_unpaid).to eq(127)
        expect(project.total_revenue_shared_unpaid).to be_a(BigDecimal)
      end

      it 'with percentage, revenue, and payments' do
        project.update(royalty_percentage: 10)
        project_award_type.awards.create_with_quantity(9, issuer: project.owner_account, authentication: authentication)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.payments.new_with_quantity(quantity_redeemed: 2, payee_auth: authentication).save!

        expect(project.total_awarded).to eq(9)
        expect(project.total_awards_outstanding).to eq(7)
        expect(project.total_revenue_shared).to eq(100)
        expect(project.payments.sum(:total_value)).to eq(22.22)

        expect(project.total_revenue_shared_unpaid).to eq(77.78)
      end
    end

    describe 'with project token awards' do
      let(:project) { create :project, payment_type: :project_token }

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared_unpaid).to eq(0)
        expect(project.total_revenue_shared_unpaid).to be_a(BigDecimal)
      end
    end
  end

  describe '#revenue_per_share' do
    describe 'with revenue sharing awards' do
      let!(:project) { create :project, payment_type: :revenue_share }

      it 'with no revenue sharing percentage entered' do
        project.update(royalty_percentage: nil)
        expect(project.revenue_per_share).to eq(0)
      end

      it 'with percentage and no revenue' do
        project.update(royalty_percentage: 10)

        expect(project.revenue_per_share).to eq(0)
        expect(project.revenue_per_share).to be_a(BigDecimal)
      end

      it 'with percentage and revenue and now shares' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.revenue_per_share).to eq(0)
        expect(project.revenue_per_share).to be_a(BigDecimal)
      end

      describe 'with percentage and revenue and shares' do
        let!(:project_award_type) { (create :award_type, project: project, amount: 7) }
        let(:issuer) { create :account }
        let(:authentication) { create :authentication }

        before do
          project_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
          project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        end

        it 'to eight decimal places' do
          expect(project.total_revenue).to eq(1270)
          expect(project.revenue_per_share).to eq(BigDecimal('3.62857142'))
          expect(project.revenue_per_share).to be_a(BigDecimal)
        end
      end

      describe 'with payments made' do
        let!(:project_award_type) { (create :award_type, project: project, amount: 7) }
        let(:issuer) { create :account }
        let(:authentication) { create :authentication }
        let(:expected_revenue_per_share) { BigDecimal('3.628571428571428571') }

        before do
          project_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
          project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        end

        it 'has right starting conditions' do
          expect(project.revenue_per_share).to eq(BigDecimal('3.62857142'))
          expect(project.total_awards_outstanding).to eq(35)
        end

        it 'deducts payments before calculating' do
          payment = project.payments.create_with_quantity(quantity_redeemed: 10,
                                                          payee_auth: authentication)

          expect(payment.total_value).to eq((10 * expected_revenue_per_share).truncate(2))
          expect(payment.total_value).to eq(36.28)
          expect(project.total_awards_outstanding).to eq(25)

          shared_revenue = 1_27
          payment_amount = 36.28
          share_portion = Rational('1/25')

          expected_revenue_per_share = (shared_revenue - payment_amount) * share_portion
          expect(project.revenue_per_share).to eq(expected_revenue_per_share)
          expect(project.revenue_per_share).to eq(3.6288)
        end
      end
    end

    describe 'with project token awards' do
      let(:project) { create :project, payment_type: :project_token }

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.revenue_per_share).to eq(0)
        expect(project.revenue_per_share).to be_a(BigDecimal)
      end
    end
  end

  describe '#share_of_revenue_unpaid' do
    describe 'with revenue sharing awards' do
      let!(:project) { create :project, payment_type: :revenue_share }

      it 'with no revenue sharing percentage entered' do
        project.update(royalty_percentage: nil)
        expect(project.share_of_revenue_unpaid(17)).to eq(0)
        expect(project.share_of_revenue_unpaid(17)).to be_a(BigDecimal)
      end

      it 'with percentage and no revenue' do
        project.update(royalty_percentage: 10)

        expect(project.share_of_revenue_unpaid(17)).to eq(0)
      end

      it 'with percentage and revenue and no shares' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.share_of_revenue_unpaid(17)).to eq(0)
        expect(project.share_of_revenue_unpaid(17)).to be_a(BigDecimal)
      end

      describe 'with percentage and revenue and shares for USD' do
        let!(:project_award_type) { (create :award_type, project: project, amount: 7) }
        let(:issuer) { create :account }
        let(:authentication) { create :authentication }

        before do
          project_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
          project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        end

        it 'returns a big decimal truncated to currency precision' do
          expect(project.total_revenue).to eq(1270)
          expect(project.total_awarded).to eq(35)
          expect(project.royalty_percentage).to eq(10)
          expect(project.total_revenue_shared).to eq(127)
          expect(project.share_of_revenue_unpaid(17)).to eq(BigDecimal('61.68'))
          expect(project.share_of_revenue_unpaid(17)).to be_a(BigDecimal)
        end

        it 'returns 0 if passed nil input' do
          expect(project.total_revenue).to eq(1270)
          expect(project.total_awarded).to eq(35)
          expect(project.royalty_percentage).to eq(10)
          expect(project.total_revenue_shared).to eq(127)
          expect(project.share_of_revenue_unpaid(nil)).to eq(BigDecimal('0'))
        end
      end

      describe 'with percentage and revenue and shares for high precision currency (ETH)' do
        let!(:project_award_type) { (create :award_type, project: project, amount: 7) }
        let(:issuer) { create :account }
        let(:authentication) { create :authentication }

        before do
          project.update(denomination: 'ETH')
          project_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'ETH', recorded_by: project.owner_account)
          project.revenues.create(amount: 270, currency: 'ETH', recorded_by: project.owner_account)
        end

        it 'returns an big decimal truncated to currency precision' do
          expect(project.total_revenue).to eq(1270)
          expect(project.total_awarded).to eq(35)
          expect(project.royalty_percentage).to eq(10)
          expect(project.total_revenue_shared).to eq(127)

          revenue_per_share = BigDecimal('3.62857142')
          expect(project.revenue_per_share).to eq(revenue_per_share)
          expect(project.share_of_revenue_unpaid(17)).to eq(revenue_per_share * 17)
        end
      end
    end

    describe 'with project token awards' do
      let(:project) { create :project, payment_type: :project_token }

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
        expect(project.total_revenue).to eq(1270)
        expect(project.share_of_revenue_unpaid(17)).to eq(0)
        expect(project.share_of_revenue_unpaid(17)).to be_a(BigDecimal)
      end
    end
  end

  describe 'with large numbers' do
    let(:billion_minus_one) { BigDecimal('999,999,999') }

    let(:project) { create :project, payment_type: :revenue_share, royalty_percentage: 100, denomination: :ETH }
    let(:big_award) { create :award_type, project: project, amount: billion_minus_one }

    before do
      big_award.awards.create_with_quantity(1,
        issuer: project.owner_account,
        authentication: project.owner_account.authentications.first)

      project.revenues.create(amount: billion_minus_one, currency: 'USD', recorded_by: project.owner_account)
    end

    it 'avoids multiplying rounding errors' do
      expect(project.total_revenue_shared).to eq(billion_minus_one)
      expect(project.share_of_revenue_unpaid(billion_minus_one)).to eq(billion_minus_one)
      expect(project.share_of_revenue_unpaid(1)).to eq(1)
    end

    it 'is resilient to multiplication rounding errors in subsequent method calls' do
      lots_of_shares = 10_000
      tiny_rev_share = project.share_of_revenue_unpaid(1)

      total = 0
      lots_of_shares.times do
        total += tiny_rev_share
      end

      expect(project.share_of_revenue_unpaid(lots_of_shares)).to eq(total)
    end

    it 'has equivilent #share_of_revenue_unpaid(1) share and #revenue_per_share' do
      expect(project.share_of_revenue_unpaid(1)).to eq(project.revenue_per_share)
    end
  end

  describe 'payments association methods' do
    let!(:project) { create :project, payment_type: :revenue_share }
    let!(:project_award_type) { (create :award_type, project: project, amount: 7) }
    let(:issuer) { create :account }
    let!(:authentication) { create :authentication }

    before do
      project_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication)
      project.update(royalty_percentage: 10)
      project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.owner_account)
      project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.owner_account)
    end

    it 'has right preconditions' do
      expect(project.total_revenue).to eq(1270)
      expect(project.revenue_per_share).to eq(BigDecimal('3.62857142'))
      expect(project.revenue_per_share).to be_a(BigDecimal)
    end

    describe 'payments.new_with_quantity' do
      let(:new_payment) { project.payments.new_with_quantity(quantity_redeemed: 10, payee_auth: authentication) }

      specify { expect(new_payment).to be_valid }
      specify { expect { new_payment.save! }.not_to raise_error }
      specify { expect(project.share_of_revenue_unpaid(1)).to eq(new_payment.share_value.truncate(2)) }
      specify { expect(new_payment.total_value).to eq(BigDecimal('36.28')) }
      specify { expect(new_payment.currency).to eq('USD') }
      specify { expect(new_payment.payee).to eq(authentication) }
    end

    describe 'payments.create_with_quantity' do
      let!(:new_payment) { project.payments.create_with_quantity(quantity_redeemed: 10, payee_auth: authentication) }
      # let!(:new_share_value) { (project.total_revenue_shared - new_payment.total_value)  }
      let(:payment_total_value) { 36.28 }
      let(:total_revenue_shared) { 127 }
      let(:total_awards_outstanding) { 25 }

      specify { expect(new_payment).to be_valid }
      specify { expect { new_payment.save! }.not_to raise_error }
      specify { expect(new_payment.share_value).to eq(BigDecimal('3.62857142')) }
      specify { expect(new_payment.total_value).to eq(BigDecimal('36.28')) }
      specify { expect(new_payment.currency).to eq('USD') }
      specify { expect(new_payment.payee).to eq(authentication) }
    end
  end

  describe 'create_ethereum_awards!' do
    let(:project) { create :project }
    let(:issuer) { create :account }
    let!(:authentication) { create :authentication }

    let!(:project_award_type) { (create :award_type, project: project, amount: 7) }
    let!(:awards) { project_award_type.awards.create_with_quantity(5, issuer: issuer, authentication: authentication) }

    specify { expect(project.awards.size).to eq(1) }

    it 'kicks of jobs to issue ethereum awards for the project' do
      expect(CreateEthereumAwards).to receive(:call).with(awards: project.awards)
      project.create_ethereum_awards!
    end
  end

  describe '#create_ethereum_contract!' do
    let(:project) { create :project }
    let(:contract_address) { '0x03b3536e825a484F796B094e63011027620bc2a9' }

    it 'kicks off an ethereum token contract job' do
      expect(Comakery::Ethereum).to receive(:token_contract).with(maxSupply: project.maximum_tokens) { contract_address }
      project.create_ethereum_contract!
      expect(project.ethereum_contract_address).to eq(contract_address)
    end
  end
end
