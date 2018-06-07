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
  let!(:award_type1) { create(:award_type, project: project, amount: 1000, name: 'Small Award') }
  let!(:award_type2) { create(:award_type, project: project, amount: 2000, name: 'Medium Award') }
  let!(:award_type3) { create(:award_type, project: project, amount: 3000, name: 'Big Award') }

  before do
    team.build_authentication_team sam_auth
    team.build_authentication_team john_auth
    team.build_authentication_team bob_auth
  end

  describe '#contributions_summary_pie_chart' do
    it "gathers extra entries into 'other'" do
      expect(described_class.new.contributions_summary_pie_chart([create(:award, unit_amount: 10, total_amount: 10, account: create(:account, first_name: 'a', last_name: 'a')), create(:award, unit_amount: 33, total_amount: 33, account: create(:account, first_name: 'b', last_name: 'b')), create(:award, unit_amount: 20, total_amount: 20, account: create(:account, first_name: 'c', last_name: 'c'))], 1)).to eq([{ net_amount: 33, name: 'b b' }, { net_amount: 30, name: 'Other' }])
    end
    it 'gathers shows all entries if less than threshold' do
      expect(described_class.new.contributions_summary_pie_chart([create(:award, unit_amount: 10, total_amount: 10, account: create(:account, first_name: 'a', last_name: 'a')), create(:award, unit_amount: 33, total_amount: 33, account: create(:account, first_name: 'b', last_name: 'b')), create(:award, unit_amount: 20, total_amount: 20, account: create(:account, first_name: 'c', last_name: 'c'))], 3)).to eq([{ net_amount: 33, name: 'b b' }, { net_amount: 20, name: 'c c' }, { net_amount: 10, name: 'a a' }])
    end
  end
end
