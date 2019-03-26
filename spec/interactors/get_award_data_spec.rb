require 'rails_helper'

describe GetAwardData do
  let!(:team) { create :team }
  let!(:sam) { create(:account, email: 'account@example.com', first_name: 'sam', last_name: 'sam') }
  let!(:sam_auth) { create(:authentication, account: sam) }
  let!(:john) { create(:account, email: 'receiver@example.com', first_name: 'john', last_name: 'john') }
  let!(:john_auth) { create(:authentication, account: john, uid: 'U8888UVMH') }
  let!(:bob) { create(:account, email: 'other@example.com', first_name: 'bob', last_name: 'bob') }
  let!(:bob_auth) { create(:authentication, account: bob) }
  let!(:project) { create(:project, title: 'Cats', account: sam) }

  before do
    team.build_authentication_team sam_auth
    team.build_authentication_team john_auth
    team.build_authentication_team bob_auth
  end

  describe '#contributor_by_day_row' do
    let!(:bobs_award) { create(:award, project: project, amount: 1000, account: bob, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award) { create(:award, project: project, amount: 2000, account: john, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award2) { create(:award, project: project, amount: 2000, account: john, created_at: Date.new(2016, 3, 2)) }

    it 'returns a row of data with defaults for missing data and summed amounts for multiple awards on the sam same day' do
      interactor = described_class.new
      template = { 'bob bob' => 0, 'sam sam' => 0, 'john john' => 0, 'some other guy' => 0 }.freeze
      expect(interactor.contributor_by_day_row(template, '20160302', [johns_award, johns_award2, bobs_award])).to eq('john john' => 4000,
                                                                                                                     'bob bob' => 1000,
                                                                                                                     'some other guy' => 0,
                                                                                                                     'sam sam' => 0,
                                                                                                                     'date' => '20160302')
    end
  end

  describe '#contributions_by_day' do
    let!(:contributor) { create :account, first_name: 'Amy', last_name: 'Win' }
    let!(:new_project) { create(:project, title: 'Dogs', account: sam) }
    let!(:award_type) { create(:award_type, project: new_project) }

    it 'return contributors by day - only return last 150' do
      create(:award, award_type: award_type, amount: 1000, quantity: 0.15, account: contributor, created_at: Time.zone.today - 200.days, updated_at: Time.zone.today - 200.days)
      result = described_class.call(project: new_project)
      h = { 'date' => (Time.zone.today - 150.days).strftime('%Y-%m-%d') }
      expect(result[:award_data][:contributions_by_day].first).to eq h
    end

    it 'return contributors by day' do
      create(:award, award_type: award_type, amount: 1000, quantity: 1, account: contributor, created_at: Time.zone.today - 10.days)
      result = described_class.call(project: new_project)
      h = { 'Amy Win' => 0.1e4, 'date' => (Time.zone.today - 10.days).strftime('%Y-%m-%d') }
      expect(result[:award_data][:contributions_by_day].first).to eq h
    end
  end
end
