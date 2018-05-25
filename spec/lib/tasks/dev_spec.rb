require 'rails_helper'

describe 'rake dev:migrate', type: :task do
  let(:auth_hash) do
    {
      'uid' => 'ACDSF',
      'provider' => 'slack',
      'credentials' => {
        'token' => 'xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa'
      },
      'extra' => {
        'user_info' => { 'user' => { 'profile' => { 'email' => 'bob@example.com', 'image_32' => 'https://avatars.com/avatars_32.jpg' } } },
        'team_info' => {
          'team' => {
            'icon' => {
              'image_34' => 'https://slack.example.com/team-image-34-px.jpg',
              'image_132' => 'https://slack.example.com/team-image-132px.jpg'
            }
          }
        }
      },
      'info' => {
        'email' => 'bob@example.com',
        'name' => 'Bob Roberts',
        'first_name' => 'Bob',
        'last_name' => 'Roberts',
        'user_id' => 'slack user id',
        'team' => 'new team name',
        'team_id' => 'slack team id',
        'user' => 'bobroberts',
        'team_domain' => 'bobrobertsdomain',
        'image' =>  Rails.root.join('spec', 'fixtures', 'helmet_cat.png')
      }
    }
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no subscribers' do
    expect { task.execute }.not_to raise_error
  end

  it 'migrate data' do
    account = create(:account, first_name: nil, last_name: nil)
    authentication = create(:authentication, account: account, oauth_response: auth_hash, slack_first_name: 'Bob', slack_last_name: 'Roberts', slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))
    project = create(:project, account: account, public: true, slack_channel: 'general')
    project1 = create(:project, account: account, public: false, slack_channel: 'general')
    award_type = create(:award_type, project: project)
    award = create(:award, authentication_id: authentication.id, award_type: award_type)

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to eq 'Roberts'
    project.reload
    project1.reload
    award.reload
    expect(project.public_listed?).to be_truthy
    expect(project1.public_listed?).to be_falsey
    expect(award.channel).to eq Channel.first
    expect(award.account).to eq account
    expect(project.channels.count).to eq 1
    expect(project1.channels.count).to eq 1
  end

  it 'migrate data skip project validation' do
    account = create(:account, first_name: nil, last_name: nil)
    authentication = create(:authentication, account: account, oauth_response: auth_hash, slack_first_name: 'Bob', slack_last_name: 'Roberts', slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))
    project = create(:project, account: account, public: true, slack_channel: 'general', license_finalized: true)
    project1 = create(:project, account: account, public: false, slack_channel: 'general')
    award_type = create(:award_type, project: project)
    award = create(:award, authentication_id: authentication.id, award_type: award_type)

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to eq 'Roberts'
    project.reload
    project1.reload
    award.reload
    expect(project.public_listed?).to be_truthy
    expect(project1.public_listed?).to be_falsey
    expect(award.channel).to eq Channel.first
    expect(award.account).to eq account
  end

  it 'migrate data - ignore missing image' do
    account = create(:account, first_name: nil, last_name: nil)
    auth_hash['info']['image'] = Rails.root.join('spec', 'fixtures', 'invalid.png')
    create(:authentication, account: account, oauth_response: auth_hash, slack_first_name: 'Bob', slack_last_name: 'Roberts', slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat1.png'))

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to eq 'Roberts'
  end

  it "migrate data - don't use slack user name if first_name, last_name exist" do
    account = create(:account, first_name: nil, last_name: nil)
    create(:authentication, account: account, oauth_response: auth_hash, slack_first_name: 'Bob', slack_last_name: 'Roberts', slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to eq 'Roberts'
    expect(account.nickname).to be_nil
  end

  it 'migrate data - use slack user name as nickname if first_name, last_name do not exist' do
    account = create(:account, first_name: nil, last_name: nil)
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to be_nil
    expect(account.last_name).to be_nil
    expect(account.nickname).to eq 'bobroberts'
  end

  it 'migrate data - do not add a nickname if the account already has a first_name' do
    account = create(:account, first_name: 'Bob', last_name: nil)
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to be_nil
    expect(account.nickname).to be_nil
  end

  it 'migrate data - do not add a nickname if the account already has a last_name' do
    account = create(:account, first_name: nil, last_name: 'Roberts')
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to be_nil
    expect(account.last_name).to eq 'Roberts'
    expect(account.nickname).to be_nil
  end

  it 'migrate data - clear the nickname if adding first name' do
    account = create(:account, nickname: 'bobroberts', first_name: nil, last_name: nil)
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_first_name: 'Bob', slack_last_name: nil, slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to be_nil
    expect(account.nickname).to be_nil
  end

  it 'migrate data - clear the nickname if adding last name' do
    account = create(:account, nickname: 'bobroberts', first_name: nil, last_name: nil)
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_first_name: nil, slack_last_name: 'Roberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to be_nil
    expect(account.last_name).to eq 'Roberts'
    expect(account.nickname).to be_nil
  end

  it 'migrate data - should fill in just account last name if first name present' do
    account = create(:account, nickname: nil, first_name: 'Randy', last_name: nil)
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_first_name: nil, slack_last_name: 'Roberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to eq 'Randy'
    expect(account.last_name).to eq 'Roberts'
    expect(account.nickname).to be_nil
  end

  it 'migrate data - should fill in just account first name if last name present' do
    account = create(:account, nickname: nil, first_name: nil, last_name: 'Jenkins')
    create(:authentication, account: account, oauth_response: auth_hash, slack_user_name: 'bobroberts', slack_first_name: 'Bob', slack_last_name: 'Roberts', slack_image_32_url: Rails.root.join('spec', 'fixtures', 'helmet_cat.png'))

    task.execute
    account.reload
    expect(account.first_name).to eq 'Bob'
    expect(account.last_name).to eq 'Jenkins'
    expect(account.nickname).to be_nil
  end
end
