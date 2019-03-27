require 'rails_helper'

describe Project do
  describe 'validations' do
    it 'requires attributes' do
      expect(described_class.new(payment_type: 'project_token').tap(&:valid?).errors.full_messages.sort)
        .to eq(["Description can't be blank",
                'Maximum tokens must be greater than 0',
                "Account can't be blank",
                "Title can't be blank",
                "Legal project owner can't be blank",
                "Long identifier can't be blank"].sort)
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
      let(:project) { create(:project, payment_type: 'revenue_share') }
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
      it 'can modify if the record has been saved' do
        project = create(:project)
        project.maximum_tokens += 10
        expect(project).to be_valid
        # expect(project.errors.full_messages).to be_include("Maximum tokens can't be changed")
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

  describe '#total_revenue' do
    let(:project_without_revenue) { create :project }
    let(:project_with_revenue) { create :project }

    before do
      project_with_revenue.revenues.create(amount: 7, currency: 'USD', recorded_by: project_with_revenue.account)
      project_with_revenue.revenues.create(amount: 11, currency: 'USD', recorded_by: project_with_revenue.account)
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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared).to eq(127)
        expect(project.total_revenue_shared).to be_a(BigDecimal)
      end
    end

    describe 'with project token awards' do
      let(:project) { create :project, payment_type: :project_token }

      it 'with percentage and revenue' do
        project.update(royalty_percentage: 10)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared).to eq(0)
        expect(project.total_revenue_shared).to be_a(BigDecimal)
      end
    end
  end

  describe '#total_revenue_shared_unpaid' do
    describe 'with revenue sharing awards' do
      let!(:project) { create :project, payment_type: :revenue_share }
      let(:account) { create :account }
      let(:project_award_type) { create :award_type, project: project }

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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        expect(project.total_revenue).to eq(1270)
        expect(project.total_revenue_shared_unpaid).to eq(127)
        expect(project.total_revenue_shared_unpaid).to be_a(BigDecimal)
      end

      it 'with percentage, revenue, and payments' do
        project.update(royalty_percentage: 10)
        create(:award, award_type: project_award_type, quantity: 9, amount: 1, issuer: project.account, account: account)
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.payments.new_with_quantity(quantity_redeemed: 2, account: account).save!

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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        expect(project.total_revenue).to eq(1270)
        expect(project.revenue_per_share).to eq(0)
        expect(project.revenue_per_share).to be_a(BigDecimal)
      end

      describe 'with percentage and revenue and shares' do
        let!(:project_award_type) { (create :award_type, project: project) }
        let(:issuer) { create :account }
        let(:account) { create :account }

        before do
          create(:award, award_type: project_award_type, quantity: 5, amount: 7, issuer: issuer, account: account)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
          project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        end

        it 'to eight decimal places' do
          expect(project.total_revenue).to eq(1270)
          expect(project.revenue_per_share).to eq(BigDecimal('3.62857142'))
          expect(project.revenue_per_share).to be_a(BigDecimal)
        end
      end

      describe 'with payments made' do
        let!(:project_award_type) { (create :award_type, project: project) }
        let(:issuer) { create :account }
        let(:account) { create :account }
        let(:expected_revenue_per_share) { BigDecimal('3.628571428571428571') }

        before do
          create(:award, award_type: project_award_type, quantity: 5, amount: 7, issuer: issuer, account: account)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
          project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        end

        it 'has right starting conditions' do
          expect(project.revenue_per_share).to eq(BigDecimal('3.62857142'))
          expect(project.total_awards_outstanding).to eq(35)
        end

        it 'deducts payments before calculating' do
          payment = project.payments.create_with_quantity(quantity_redeemed: 10,
                                                          account: account)

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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        expect(project.total_revenue).to eq(1270)
        expect(project.share_of_revenue_unpaid(17)).to eq(0)
        expect(project.share_of_revenue_unpaid(17)).to be_a(BigDecimal)
      end

      describe 'with percentage and revenue and shares for USD' do
        let!(:project_award_type) { (create :award_type, project: project) }
        let(:issuer) { create :account }
        let(:account) { create :account }

        before do
          create(:award, award_type: project_award_type, quantity: 5, amount: 7, issuer: issuer, account: account)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
          project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
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
        let!(:project_award_type) { (create :award_type, project: project) }
        let(:issuer) { create :account }
        let(:account) { create :account }

        before do
          project.token.update(denomination: 'ETH')
          create(:award, award_type: project_award_type, quantity: 5, amount: 7, issuer: issuer, account: account)
          project.update(royalty_percentage: 10)
          project.revenues.create(amount: 1000, currency: 'ETH', recorded_by: project.account)
          project.revenues.create(amount: 270, currency: 'ETH', recorded_by: project.account)
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
        project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
        project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
        expect(project.total_revenue).to eq(1270)
        expect(project.share_of_revenue_unpaid(17)).to eq(0)
        expect(project.share_of_revenue_unpaid(17)).to be_a(BigDecimal)
      end
    end
  end

  describe 'with large numbers' do
    let(:billion_minus_one) { BigDecimal('999,999,999') }

    let(:project) { create :project, payment_type: :revenue_share, royalty_percentage: 100, token: create(:token, denomination: :ETH) }
    let(:big_award) { create :award_type, project: project }

    before do
      create(:award, award_type: big_award, quantity: 1, amount: billion_minus_one, issuer: project.account, account: project.account)

      project.revenues.create(amount: billion_minus_one, currency: 'USD', recorded_by: project.account)
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
    let!(:project_award_type) { (create :award_type, project: project) }
    let(:issuer) { create :account }
    let!(:account) { create :account }

    before do
      create(:award, award_type: project_award_type, quantity: 5, amount: 7, issuer: project.account, account: account)
      project.update(royalty_percentage: 10)
      project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
      project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
    end

    it 'has right preconditions' do
      expect(project.total_revenue).to eq(1270)
      expect(project.revenue_per_share).to eq(BigDecimal('3.62857142'))
      expect(project.revenue_per_share).to be_a(BigDecimal)
    end

    describe 'payments.new_with_quantity' do
      let(:new_payment) { project.payments.new_with_quantity(quantity_redeemed: 10, account: account) }

      specify { expect(new_payment).to be_valid }
      specify { expect { new_payment.save! }.not_to raise_error }
      specify { expect(project.share_of_revenue_unpaid(1)).to eq(new_payment.share_value.truncate(2)) }
      specify { expect(new_payment.total_value).to eq(BigDecimal('36.28')) }
      specify { expect(new_payment.currency).to eq('USD') }
      specify { expect(new_payment.account).to eq(account) }
    end

    describe 'payments.create_with_quantity' do
      let!(:new_payment) { project.payments.create_with_quantity(quantity_redeemed: 10, account: account) }
      # let!(:new_share_value) { (project.total_revenue_shared - new_payment.total_value)  }
      let(:payment_total_value) { 36.28 }
      let(:total_revenue_shared) { 127 }
      let(:total_awards_outstanding) { 25 }

      specify { expect(new_payment).to be_valid }
      specify { expect { new_payment.save! }.not_to raise_error }
      specify { expect(new_payment.share_value).to eq(BigDecimal('3.62857142')) }
      specify { expect(new_payment.total_value).to eq(BigDecimal('36.28')) }
      specify { expect(new_payment.currency).to eq('USD') }
      specify { expect(new_payment.account).to eq(account) }
    end
  end

  describe 'create_ethereum_awards!' do
    let(:project) { create :project }
    let(:issuer) { create :account }
    let!(:account) { create :account }

    let!(:project_award_type) { (create :award_type, project: project) }
    let!(:awards) { create(:award, award_type: project_award_type, quantity: 5, amount: 7, issuer: issuer, account: account) }

    specify { expect(project.awards.size).to eq(1) }

    it 'kicks of jobs to issue ethereum awards for the project' do
      expect(CreateEthereumAwards).to receive(:call).with(awards: project.awards)
      project.create_ethereum_awards!
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

  it 'check share revenue' do
    project = create :project
    expect(project.share_revenue?).to eq false
    project.revenue_share!
    project.update royalty_percentage: 0
    expect(project.share_revenue?).to eq false
    project.update royalty_percentage: 10
    expect(project.share_revenue?).to eq true
  end

  it 'check if user can access revenue info' do
    account = create :account
    other_account = create :account
    project = create :project, account: account
    expect(project.share_revenue?).to eq false
    project.revenue_share!
    project.update royalty_percentage: 0
    expect(project.share_revenue?).to eq false
    expect(project.show_revenue_info?(account)).to eq false
    project.update royalty_percentage: 10
    expect(project.share_revenue?).to eq true
    expect(project.show_revenue_info?(account)).to eq true
    expect(project.show_revenue_info?(other_account)).to eq false
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
