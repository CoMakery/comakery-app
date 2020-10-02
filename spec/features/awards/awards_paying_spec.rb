require 'rails_helper'

describe 'awarding users' do
  let!(:team) { create :team }
  let!(:other_team) { create :team }
  let!(:account) { create(:account, email: 'hubert@example.com', first_name: 'Michael', last_name: 'Jackson') }
  let!(:other_account) { create(:account, email: 'sherman@example.com') }
  let!(:different_team_account) { create(:account, email: 'different@example.com') }

  let!(:owner_authentication) { create(:authentication, account: account) }
  let!(:other_authentication) { create(:authentication, account: other_account) }
  let!(:different_team_authentication) { create(:authentication, account: different_team_account) }

  let!(:project) do
    stub_token_symbol
    create(:project, title: 'Project that needs awards', account: account, maximum_tokens: 10000000, token: create(:token, ethereum_enabled: true, contract_address: build(:ethereum_contract_address), _token_type: 'erc20', _blockchain: :ethereum_ropsten))
  end
  let!(:same_team_project) { create(:project, title: 'Same Team Project', account: account) }
  let!(:different_team_project) { create(:project, visibility: 'public_listed', title: 'Different Team Project', account: different_team_account) }

  let!(:channel) { create(:channel, team: team, project: project, channel_id: 'channel id') }
  let!(:other_channel) { create(:channel, team: other_team, project: different_team_project, name: 'other channel') }

  let!(:small_award_type) { create(:award_type, project: project, name: 'Small') }
  let!(:large_award_type) { create(:award_type, project: project, name: 'Large') }

  let!(:same_team_small_award_type) { create(:award_type, project: same_team_project, name: 'Small') }
  let!(:same_team_small_award) { create(:award, issuer: account, account: account, award_type: same_team_small_award_type, amount: 10) }

  let!(:different_large_award_type) { create(:award_type, project: different_team_project, name: 'Large') }
  let!(:different_large_award) { create(:award, issuer: different_team_account, award_type: different_large_award_type, amount: 3000, account: different_team_account) }

  before do
    team.build_authentication_team owner_authentication
    team.build_authentication_team other_authentication
    other_team.build_authentication_team different_team_authentication

    travel_to(DateTime.parse('Mon, 29 Feb 2016 00:00:00 +0000')) # so we can check for fixed date of award

    stub_slack_user_list([{ "id": 'U99M9QYFQ', "team_id": 'team id', "name": 'bobjohnson', "profile": { "email": 'bobjohnson@example.com' } }])
    stub_request(:post, 'https://slack.com/api/users.info').to_return(body: {
      ok: true,
      "user": {
        "id": 'U99M9QYFQ',
        "team_id": 'team id',
        "name": 'bobjohnson',
        "profile": {
          email: 'bobjohnson@example.com'
        }
      }
    }.to_json)
  end

  after do
    travel_back
  end

  it 'list awards' do
    project.token.update decimal_places: 2
    receiver = create :account, email: 'test@test.st'
    create :wallet, account: receiver, address: '0x' + 'b' * 40, _blockchain: project.token._blockchain
    create :award, account: receiver, award_type: small_award_type, amount: 1000
    login(account)
    visit awards_project_path(project)
    expect(page).to have_content '1,000'
    expect(page).to have_content 'Send'
  end
end
