require 'rails_helper'

describe GetContributorData do
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

  describe '#contributions_summary_pie_chart' do
    it "gathers extra entries into 'other'" do
      expect(described_class.new.contributions_summary_pie_chart([
                                                                   create(
                                                                     :award,
                                                                     amount: 1,
                                                                     account: create(
                                                                       :account,
                                                                       first_name: 'a',
                                                                       last_name: 'a'
                                                                     )
                                                                   ),
                                                                   create(
                                                                     :award,
                                                                     amount: 33,
                                                                     account: create(
                                                                       :account,
                                                                       first_name: 'b',
                                                                       last_name: 'b'
                                                                     )
                                                                   ),
                                                                   create(
                                                                     :award,
                                                                     amount: 200,
                                                                     account: create(
                                                                       :account,
                                                                       first_name: 'c',
                                                                       last_name: 'c'
                                                                     )
                                                                   )
                                                                 ])).to eq([
                                                                             { name: 'b b', net_amount: 33 },
                                                                             { name: 'c c', net_amount: 200 },
                                                                             { name: 'Other', net_amount: 1 }
                                                                           ])
    end

    it 'gathers shows all entries if less than threshold' do
      expect(described_class.new.contributions_summary_pie_chart([
                                                                   create(
                                                                     :award,
                                                                     amount: 10,
                                                                     account: create(
                                                                       :account,
                                                                       first_name: 'a',
                                                                       last_name: 'a'
                                                                     )
                                                                   ),
                                                                   create(
                                                                     :award,
                                                                     amount: 33,
                                                                     account: create(
                                                                       :account,
                                                                       first_name: 'b',
                                                                       last_name: 'b'
                                                                     )
                                                                   ),
                                                                   create(
                                                                     :award,
                                                                     amount: 20,
                                                                     account: create(
                                                                       :account,
                                                                       first_name: 'c',
                                                                       last_name: 'c'
                                                                     )
                                                                   )
                                                                 ])).to eq([
                                                                             { name: 'a a', net_amount: 10 },
                                                                             { name: 'b b', net_amount: 33 },
                                                                             { name: 'c c', net_amount: 20 }
                                                                           ])
    end

    it 'handles missing token correctly' do
      project = create(:project)
      project.update(token: nil)
      award = create(:award, amount: 10, award_type: create(:award_type, project: project))
      expect(described_class.new.contributions_summary_pie_chart([award])).to eq([{ name: award.account.decorate.name, net_amount: 10 }])
    end
  end
end
