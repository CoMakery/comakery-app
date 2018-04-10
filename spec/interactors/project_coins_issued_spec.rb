require 'rails_helper'

describe ProjectTokensIssued do
  let!(:team) { create :team }
  let!(:project) { create(:sb_project) }
  let!(:auth1) { create(:sb_authentication) }
  let!(:auth2) { create(:sb_authentication) }
  let!(:account1) { auth1.account }
  let!(:account2) { auth2.account }
  let!(:award_type_1) { create(:award_type, project: project, amount: 1) }
  let!(:award_type_2) { create(:award_type, project: project, amount: 2) }
  let!(:award_type_4) { create(:award_type, project: project, amount: 4) }

  let!(:cc_project) { create(:cc_project) }
  let!(:cc_award) { create(:award, award_type: create(:award_type, project: cc_project, amount: 1000)) }

  before do
    team.build_authentication_team auth1
    team.build_authentication_team auth2
  end

  it 'returns 0 for projects with no awards' do
    project = create(:project)

    expect(described_class.call(project: project).total_tokens_issued).to eq(0)

    create(:award_type, project: project)

    expect(described_class.call(project: project).total_tokens_issued).to eq(0)
  end

  describe do
    before do
      create(:award, account: account1, award_type: award_type_1)
      create(:award, account: account1, award_type: award_type_2)
      create(:award, account: account1, award_type: award_type_4)

      create(:award, account: account2, award_type: award_type_1)
      create(:award, account: account2, award_type: award_type_2)
      create(:award, account: account2, award_type: award_type_4)
    end

    it 'returns the total amount of tokens awarded for a project' do
      result = described_class.call(project: project)
      expect(result).to be_success
      expect(result.total_tokens_issued).to eq(1 + 2 + 4 +
                                                  1 + 2 + 4)
    end

    it 'returns the total amount of tokens awarded for a project with multiple award.quantity' do
      create(:award, account: account2, award_type: award_type_4, quantity: 2)

      result = described_class.call(project: project)
      expect(result).to be_success
      expect(result.total_tokens_issued).to eq(1 + 2 + 4 + 1 + 2 + 4 +
                                                  8)
    end
  end
end
