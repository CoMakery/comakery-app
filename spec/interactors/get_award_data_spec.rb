require 'rails_helper'

describe GetAwardData do
  let!(:team) { create :team }
  let!(:sam) { create(:account, email: 'account@example.com', first_name: 'sam', last_name: 'sam') }
  let!(:sam_auth) { create(:authentication, account: sam) }
  let!(:john) { create(:account, email: 'receiver@example.com', first_name: 'john') }
  let!(:john_auth) { create(:authentication, account: john, uid: 'U8888UVMH') }
  let!(:bob) { create(:account, email: 'other@example.com', first_name: 'bob', last_name: 'bob') }
  let!(:bob_auth) { create(:authentication, account: bob) }
  let!(:project) { create(:project, title: 'Cats', account: sam) }
  let!(:award_type1) { create(:award_type, project: project, amount: 1000, name: 'Small Award') }
  let!(:award_type2) { create(:award_type, project: project, amount: 2000, name: 'Medium Award') }
  let!(:award_type3) { create(:award_type, project: project, amount: 3000, name: 'Big Award') }

  before do
    team.build_authentication_team sam_auth
    team.build_authentication_team john_auth
    team.build_authentication_team bob_auth
  end

  describe '#call' do
    let!(:sam_award_1) { create(:award, award_type: award_type1, quantity: 0.15, account: sam, created_at: Date.new(2016, 1, 1)) }

    let!(:john_award_1) { create(:award, award_type: award_type1, quantity: 2, account: john, created_at: Date.new(2016, 2, 8)) }
    let!(:john_award_2) { create(:award, award_type: award_type1, quantity: 2, account: john, created_at: Date.new(2016, 3, 1)) }
    let!(:john_award_3) { create(:award, award_type: award_type2, quantity: 2, account: john, created_at: Date.new(2016, 3, 2)) }
    let!(:john_award_4) { create(:award, award_type: award_type3, quantity: 2, account: john, created_at: Date.new(2016, 3, 8)) }

    let!(:bob_award_1) { create(:award, award_type: award_type1, quantity: 2, account: bob, created_at: Date.new(2016, 3, 2)) }
    let!(:bob_award_2) { create(:award, award_type: award_type2, quantity: 2, account: bob, created_at: Date.new(2016, 3, 8)) }

    before do
      travel_to Date.new(2016, 3, 8)
    end

    it "doesn't explode if you aren't logged in" do
      result = described_class.call(account: nil, project: project)
      expect(result.award_data[:award_amounts]).to eq(my_project_tokens: nil, total_tokens_issued: 20_150.0)
    end

    it 'returns a pretty hash of the awards for a project with summed amounts for each person' do
      result = described_class.call(account: sam, project: project)

      expect(result.award_data[:contributions]).to match_array([{ net_amount: 14000, name: 'john', avatar: nil },
                                                                { net_amount: 6000, name: 'bob bob', avatar: nil },
                                                                { net_amount: 150.0, name: 'sam sam', avatar: nil }])

      expect(result.award_data[:award_amounts]).to eq(my_project_tokens: 150.0, total_tokens_issued: 20_150.0)
    end

    it 'shows values for each contributor for all 30 days' do
      result = described_class.call(account: sam, project: project)

      awarded_account_names = Award.select('account_id, max(id) as id').group('account_id').all.map { |a| a.account.name }
      expect(awarded_account_names).to match_array(['john', 'sam sam', 'bob bob'])

      contributions = result.award_data[:contributions_by_day].select do |cbd|
        cbd['john'] > 0
      end

      expect(contributions).to eq([
                                    { 'date' => '2016-02-08', 'sam sam' => 0, 'john' => 2000.0, 'bob bob' => 0 },
                                    { 'date' => '2016-03-01', 'sam sam' => 0, 'john' => 2000.0, 'bob bob' => 0 },
                                    { 'date' => '2016-03-02', 'sam sam' => 0, 'john' => 4000.0, 'bob bob' => 2000.0 },
                                    { 'date' => '2016-03-08', 'sam sam' => 0, 'john' => 6000.0, 'bob bob' => 4000.0 }
                                  ])
    end
  end

  describe '#contributions_data' do
    it 'sorts by amount' do
      expect(described_class.new.contributions_data(
               [
                 create(:award, award_type: create(:award_type, amount: 1000), account: create(:account, first_name: 'a', last_name: 'a')),
                 create(:award, award_type: create(:award_type, amount: 3000), account: create(:account, first_name: 'b', last_name: 'b')),
                 create(:award, award_type: create(:award_type, amount: 2000), account: create(:account, first_name: 'c', last_name: 'c'))
               ]
      )).to eq([
                 { net_amount: 3000, name: 'b b', avatar: nil },
                 { net_amount: 2000, name: 'c c', avatar: nil },
                 { net_amount: 1000, name: 'a a', avatar: nil }
               ])
    end
  end

  describe '#contributions_summary' do
    context 'with no awards' do
      specify do
        contributions = described_class.new.contributions_summary(project)
        expect(contributions).to eq []
      end
    end

    context 'with awards' do
      let!(:sam_award_1) { create(:award, award_type: award_type1, account: sam, created_at: Date.new(2016, 1, 1)) }
      let!(:john_award_1) { create(:award, award_type: award_type1, account: john, created_at: Date.new(2016, 2, 8)) }
      let!(:john_award_2) { create(:award, award_type: award_type1, account: john, created_at: Date.new(2016, 3, 1)) }
      let!(:john_payment) do
        create(:payment, account: john, issuer: sam, project: project, total_value: 10,
                         share_value: 1, quantity_redeemed: 10)
      end
      let!(:sam_payment) do
        create(:payment, account: sam, issuer: sam, project: project,
                         share_value: 1, total_value: 5, quantity_redeemed: 5)
      end

      specify do
        contributions = described_class.new.contributions_summary(project)
        expect(contributions).to eq([
                                      { name: 'john',
                                        avatar: nil,
                                        earned: 2000,
                                        paid: 10,
                                        remaining: 1990 },
                                      { name: 'sam sam',
                                        avatar: nil,
                                        earned: 1000,
                                        paid: 5,
                                        remaining: 995 }
                                    ])
      end
    end
  end

  describe '#contributions_summary_pie_chart' do
    it "gathers extra entries into 'other'" do
      expect(described_class.new.contributions_summary_pie_chart([create(:award, unit_amount: 10, total_amount: 10, account: create(:account, first_name: 'a', last_name: 'a')), create(:award, unit_amount: 33, total_amount: 33, account: create(:account, first_name: 'b', last_name: 'b')), create(:award, unit_amount: 20, total_amount: 20, account: create(:account, first_name: 'c', last_name: 'c'))], 1)).to eq([{ net_amount: 33, name: 'b b', avatar: nil }, { net_amount: 30, name: 'Other' }])
    end
    it 'gathers shows all entries if less than threshold' do
      expect(described_class.new.contributions_summary_pie_chart([create(:award, unit_amount: 10, total_amount: 10, account: create(:account, first_name: 'a', last_name: 'a')), create(:award, unit_amount: 33, total_amount: 33, account: create(:account, first_name: 'b', last_name: 'b')), ceate(:award, unit_amount: 20, total_amount: 20, account: create(:account, first_name: 'c', last_name: 'c'))], 3)).to eq([{ net_amount: 33, name: 'b b', avatar: nil }, { net_amount: 20, name: 'c c', avatar: nil }, { net_amount: 10, name: 'a a', avatar: nil }])
    end
  end

  describe '#contributor_by_day_row' do
    let!(:bobs_award) { create(:award, award_type: award_type1, account: bob, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award) { create(:award, award_type: award_type2, account: john, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award2) { create(:award, award_type: award_type2, account: john, created_at: Date.new(2016, 3, 2)) }

    it 'returns a row of data with defaults for missing data and summed amounts for multiple awards on the sam same day' do
      interactor = described_class.new
      template = { 'bob bob' => 0, 'sam sam' => 0, 'john' => 0, 'some other guy' => 0 }.freeze
      expect(interactor.contributor_by_day_row(template, '20160302', [johns_award, johns_award2, bobs_award])).to eq('john' => 4000,
                                                                                                                     'bob bob' => 1000,
                                                                                                                     'some other guy' => 0,
                                                                                                                     'sam sam' => 0,
                                                                                                                     'date' => '20160302')
    end
  end
end
