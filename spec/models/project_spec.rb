require 'rails_helper'

describe Project do
  describe 'validations' do
    it 'requires attributes' do
      expect(Project.new.tap(&:valid?).errors.full_messages.sort).to eq(["Description can't be blank",
                                                                         "Maximum coins must be greater than 0",
                                                                         "Owner account can't be blank",
                                                                         "Slack channel can't be blank",
                                                                         "Slack team can't be blank",
                                                                         "Slack team image 132 url can't be blank",
                                                                         "Slack team image 34 url can't be blank",
                                                                         "Slack team name can't be blank",
                                                                         "Title can't be blank",
                                                                        ])

      expect(Project.new(slack_team_domain: "").tap { |p| p.valid? }.errors.full_messages).to be_include("Slack team domain can't be blank")
      expect(Project.new(slack_team_domain: "XX").tap { |p| p.valid? }.errors.full_messages).to be_include("Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number")
      expect(Project.new(slack_team_domain: "-xx").tap { |p| p.valid? }.errors.full_messages).to be_include("Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number")
      expect(Project.new(slack_team_domain: "good\n-bad").tap { |p| p.valid? }.errors.full_messages).to be_include("Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number")

      expect(Project.new(slack_team_domain: "3-xx").tap { |p| p.valid? }.errors.full_messages).not_to be_include("Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number")
      expect(Project.new(slack_team_domain: "a").tap { |p| p.valid? }.errors.full_messages).not_to be_include("Slack team domain must only contain lower-case letters, numbers, and hyphens and start with a letter or number")
    end

    describe :royalty_percentage do
      it 'has high precision' do
        project = create :project, royalty_percentage: '99.999_999_999_999_9'
        project.reload
        expect(project.royalty_percentage).to eq(BigDecimal('99.999_999_999_999_9'))
      end

      it 'can represent 100%' do
        project = create :project, royalty_percentage: '100'
        project.reload
        expect(project.royalty_percentage).to eq(100.0)
      end
    end

    describe "payment_type" do
      let(:project) { create(:project) }
      let(:order) { [:royalty_usd, :project_coin, :royalty_btc, :royalty_eth] }

      it 'defaults to project_coin' do
        expect(project.payment_type).to eq('royalty_usd')
      end


      it 'has the correct enum index values' do
        order.each_with_index do |item, index|
          expect(Project.payment_types[item]).to eq index
        end
      end
    end

    describe "maximum_coins" do
      it "prevents modification if the record has been saved" do
        project = create(:project)
        project.maximum_coins += 10
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to be_include("Maximum coins can't be changed")
      end
    end

    describe "ethereum_enabled" do
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
        expect(project.tap(&:valid?).errors.full_messages.first).
            to eq("Ethereum enabled cannot be set to false after it has been set to true")
      end
    end

    describe "#ethereum_contract_address" do
      let(:project) { create(:project) }
      let(:address) { '0x'+'a'*40 }

      it "should validate with a valid ethereum address" do
        expect(build(:project, ethereum_contract_address: nil)).to be_valid
        expect(build(:project, ethereum_contract_address: "0x#{'a'*40}")).to be_valid
        expect(build(:project, ethereum_contract_address: "0x#{'A'*40}")).to be_valid
      end

      it "should not validate with an invalid ethereum address" do
        expected_error_message = "Ethereum contract address should start with '0x', followed by a 40 character ethereum address"
        expect(build(:project, ethereum_contract_address: "foo").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x#{'a'*39}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x#{'a'*41}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
        expect(build(:project, ethereum_contract_address: "0x#{'g'*40}").tap(&:valid?).errors.full_messages).to eq([expected_error_message])
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
        project.ethereum_contract_address = '0x'+'b'*40
        expect(project).not_to be_valid
        expect(project.errors.full_messages.to_sentence).to match \
          /Ethereum contract address cannot be changed after it has been set/
      end
    end

    describe "tracker" do
      it "is valid if tracker is a valid, absolute url" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", tracker: "http://foo.com", maximum_coins: 10_000_000)
        expect(project).to be_valid
        expect(project.tracker).to eq("http://foo.com")
      end

      it "doesn't allow completely wrong urls that cause parsing errors" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", tracker: "ゆアルエル", maximum_coins: 10_000_000)
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(["Tracker must be a valid url"])
      end

      it "requires the tracker url be valid if present" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", tracker: "foo", maximum_coins: 10_000_000)
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(["Tracker must be a valid url"])
      end

      it "is valid with no tracker specified" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", tracker: nil, maximum_coins: 10_000_000)
        expect(project).to be_valid
      end

      it "is valid if tracker is blank" do
        project = Project.create!(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", tracker: "", maximum_coins: 10_000_000)
        expect(project.tracker).to be_nil
      end
    end

    describe "video_url" do
      it "is valid if video_url is a valid, absolute url, the domain is youtube.com, and there is the identifier inside" do
        expect(build(:sb_project, video_url: "https://youtube.com/watch?v=Dn3ZMhmmzK0")).to be_valid
        expect(build(:sb_project, video_url: "https://youtube.com/embed/Dn3ZMhmmzK0")).to be_valid
        expect(build(:sb_project, video_url: "https://youtu.be/jJrzIdDUfT4")).to be_valid

        expect(build(:sb_project, video_url: "https://youtube.com/embed/")).not_to be_valid
        expect(build(:sb_project, video_url: "https://youtu.be/")).not_to be_valid
        expect(build(:sb_project, video_url: "https://youtu.be/").tap(&:valid?).errors.full_messages).to eq(["Video url must be a Youtube link like 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'"])
      end

      it "doesn't allow completely wrong urls that cause parsing errors" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", video_url: "ゆアルエル", maximum_coins: 10_000_000)
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(["Video url must be a valid url"])
      end

      it "requires the video_url url be valid if present" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", video_url: "foo", maximum_coins: 10_000_000)
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to match_array(["Video url must be a valid url"])
      end

      it "is valid with no video_url specified" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", video_url: nil, maximum_coins: 10_000_000)
        expect(project).to be_valid
      end

      it "is valid if video_url is blank" do
        project = Project.create!(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", video_url: "", maximum_coins: 10_000_000)
        expect(project.video_url).to be_nil
      end
    end

    describe "contributor_agreement_url" do
      it "is valid if contributor_agreement_url is a valid, absolute url" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", contributor_agreement_url: "http://foo.com", maximum_coins: 10_000_000)
        expect(project).to be_valid
        expect(project.contributor_agreement_url).to eq("http://foo.com")
      end

      it "doesn't allow completely wrong urls that cause parsing errors" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", contributor_agreement_url: "ゆアルエル", maximum_coins: 10_000_000)
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(["Contributor agreement url must be a valid url"])
      end

      it "requires the contributor_agreement_url be valid if present" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", contributor_agreement_url: "foo", maximum_coins: 10_000_000)
        expect(project).not_to be_valid
        expect(project.errors.full_messages).to eq(["Contributor agreement url must be a valid url"])
      end

      it "is valid with no contributor_agreement_url specified" do
        project = Project.new(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", contributor_agreement_url: nil, maximum_coins: 10_000_000)
        expect(project).to be_valid
      end

      it "is valid if contributor_agreement_url is blank" do
        project = Project.create!(description: "foo", owner_account: create(:account), title: "title", slack_team_id: "bar", slack_channel: "slack_channel", slack_team_name: "baz", slack_team_image_34_url: "happy-34.gif", slack_team_image_132_url: "happy-132.gif", contributor_agreement_url: "", maximum_coins: 10_000_000)
        expect(project.contributor_agreement_url).to be_nil
      end
    end
  end

  describe 'associations' do
    it 'has many award_types and accepts them as nested attributes' do
      project = Project.create!(description: "foo",
                                title: 'This is a title',
                                owner_account: create(:account),
                                slack_team_id: '123',
                                slack_channel: "slack_channel",
                                slack_team_name: 'This is a slack team name',
                                slack_team_image_34_url: 'http://foo.com/kittens-34.jpg',
                                slack_team_image_132_url: 'http://foo.com/kittens-132.jpg',
                                maximum_coins: 10_000_000,
                                award_types_attributes: [
                                    {'name' => 'Small award', 'amount' => '1000'},
                                    {'name' => '', 'amount' => '1000'},
                                    {'name' => 'Award', 'amount' => ''}
                                ])

      expect(project.award_types.count).to eq(1)
      expect(project.award_types.first.name).to eq('Small award')
      expect(project.award_types.first.amount).to eq(1000)
      expect(project.slack_team_id).to eq('123')
      expect(project.slack_team_name).to eq('This is a slack team name')
      expect(project.slack_team_image_34_url).to eq('http://foo.com/kittens-34.jpg')
      expect(project.slack_team_image_132_url).to eq('http://foo.com/kittens-132.jpg')

      project.update(award_types_attributes: {id: project.award_types.first.id, _destroy: true})
      expect(project.award_types.count).to eq(0)
    end
  end

  describe 'scopes' do
    describe ".with_last_activity_at" do
      it "returns projects ordered by when the most recent award created_at, then by project created_at" do
        p1_8 = create(:project, title: "p1_8", created_at: 8.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 1.days.ago) } }
        p2_3 = create(:project, title: "p2_3", created_at: 3.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 2.days.ago) } }
        p3_6 = create(:project, title: "p3_6", created_at: 6.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }
        p3_5 = create(:project, title: "p3_5", created_at: 5.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }
        p3_4 = create(:project, title: "p3_4", created_at: 4.days.ago).tap { |p| create(:award_type, project: p).tap { |at| create(:award, award_type: at, created_at: 3.days.ago) } }

        expect(Project.count).to eq(5)
        expect(Project.with_last_activity_at.all.map(&:title)).to eq(%w(p1_8 p2_3 p3_4 p3_5 p3_6))
      end

      describe "#for_account #not_for_account" do
        it "returns all projects for the given account's slack auth" do
          account = create(:account).tap do |a|
            create(:authentication, account: a, slack_team_id: "foo", updated_at: 1.days.ago)
            create(:authentication, account: a, slack_team_id: "bar", updated_at: 2.days.ago)
          end
          account2 = create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "qux") }

          foo_project = create(:project, slack_team_id: "foo", title: "Foo")
          foo2_project = create(:project, slack_team_id: "foo", title: "Foo2")
          bar_project = create(:project, slack_team_id: "bar", title: "Bar")
          qux_project = create(:project, slack_team_id: "qux", title: "Qux")

          expect(Project.for_account(account).pluck(:title)).to match_array(%w(Foo Foo2))
          expect(Project.not_for_account(account).pluck(:title)).to match_array(%w(Bar Qux))
        end
      end
    end

    describe "#community_award_types" do
      it "returns all award types with community_awardable? == true" do
        project = create(:project)
        community_award_type = create(:award_type, project: project, community_awardable: true)
        normal_award_type = create(:award_type, project: project, community_awardable: false)

        expect(project.community_award_types).to eq([community_award_type])
      end
    end
  end

  describe "#owner_slack_user_name" do
    let!(:owner) { create :account }
    let!(:project) { create :project, owner_account: owner, slack_team_id: 'reds' }

    it "returns the user name" do
      create(:authentication, account: owner, slack_team_id: 'reds', slack_first_name: "John", slack_last_name: "Doe", slack_user_name: 'johnny')
      expect(project.owner_slack_user_name).to eq('John Doe')
    end

    it "returns the user name for the correct auth, even if older" do
      travel_to Date.new(2015)
      create(:authentication, account: owner, slack_team_id: 'reds', slack_first_name: "John", slack_last_name: "Red", slack_user_name: 'johnny')
      travel_to Date.new(2016)
      create(:authentication, account: owner, slack_team_id: 'blues', slack_first_name: "John", slack_last_name: "Blue", slack_user_name: 'johnny')
      expect(project.owner_slack_user_name).to eq('John Red')
    end

    it "doesn't blow up if the isn't an auth" do
      expect(project.owner_slack_user_name).to be_nil
    end
  end

  describe "#transitioned_to_ethereum_enabled?" do
    it "should trigger if new project is saved with ethereum_enabled = true" do
      project = build(:project, ethereum_enabled: true)
      project.save!
      expect(project.transitioned_to_ethereum_enabled?).to eq(true)
    end

    it "should trigger if existing project is saved with ethereum_enabled = true" do
      project = create(:project, ethereum_enabled: false)
      project.update!(ethereum_enabled: true)
      expect(project.transitioned_to_ethereum_enabled?).to eq(true)
    end

    it "should not trigger if new project is saved with ethereum_enabled = false" do
      project = build(:project, ethereum_enabled: false)
      project.save!
      expect(project.transitioned_to_ethereum_enabled?).to eq(false)
    end

    it "should be false if an existing project with an account is transitioned from ethereum_enabled = false to true" do
      project = create(:project, ethereum_enabled: false, ethereum_contract_address: '0x' + '7' *40)
      project.update!(ethereum_enabled: true)
      expect(project.transitioned_to_ethereum_enabled?).to eq(false)
    end
  end

  describe '#legal_terms_finalized?' do
    let(:project) { create :project }

    it 'is not finalized after first save' do
      expect(project.legal_terms_finalized?).to eq false
    end

    it "is finalized after first award is issued" do
      create(:award_type, project: project).tap { |at| create(:award, award_type: at, created_at: 1.second.ago) }
      expect(project.legal_terms_finalized?).to eq(true)
    end

    it "is finalized after ethereum contract created" do
      expect(project).to receive(:transitioned_to_ethereum_enabled?) { true }
      expect(project.legal_terms_finalized?).to eq(true)
    end
  end
end
