require 'rails_helper'

describe SendAward do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:authentication) { create :authentication }
  let!(:issuer) { authentication.account }
  let!(:other_auth) { create(:authentication, account: issuer, token: 'token') }
  let!(:discord_auth) { create(:authentication, account: issuer, token: 'discord_token', provider: 'discord') }
  let!(:project) { create(:project, account: issuer) }
  let!(:other_project) { create(:project, account: create(:account)) }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award) { create(:award, award_type: award_type) }

  let(:recipient) { create(:account, email: 'glenn@example.com') }
  let(:recipient_authentication) { create(:authentication, account: recipient) }
  let!(:recipient_discord_auth) { create(:authentication, account: recipient, provider: 'discord') }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team recipient_authentication
    discord_team.build_authentication_team discord_auth
    discord_team.build_authentication_team recipient_discord_auth
    project.channels.create(team: team, channel_id: 'channel_id', name: 'slack_channel')
  end

  context 'send email award' do
    it 'send award notification to email' do
      result = described_class.call(
        award: award,
        email: 'test@test.st'
      )
      expect(result.award.confirm_token).not_to be_nil
      expect(result.award.email).to eq 'test@test.st'
    end

    it 'fails with invalid email' do
      result = described_class.call(
        award: award,
        email: 'invalid email'
      )
      expect(result.award.valid?).to eq(false)
      expect(result.award.errors.full_messages).to eq(['Email is invalid'])
    end
  end

  context 'when the account/auth exists already in the db' do
    it 'builds a award for the given slack user id with the matching account from the db' do
      recipient
      recipient_authentication
      result = nil
      expect do
        expect do
          expect do
            result = described_class.call(
              award: award,
              channel_id: project.channels.first.id,
              uid: recipient_authentication.uid
            )
            expect(result).to be_success
            expect(result.award.award_type).to eq(award_type)
            expect(result.award.account).to eq(recipient)
          end.not_to(change { Award.count })
        end.not_to(change { Authentication.count })
      end.not_to(change { Account.count })
      expect(result.award.save).to eq(true)
    end

    it 'builds a award for the given discord user id with the matching account from the db' do
      stub_discord_channels
      channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'discord_channel')
      result = nil
      expect do
        expect do
          expect do
            result = described_class.call(
              award: award,
              channel_id: channel.id,
              uid: recipient_authentication.uid
            )
            expect(result).to be_success
            expect(result.award.award_type).to eq(award_type)
            expect(result.award.account).to eq(recipient)
          end.not_to(change { Award.count })
        end.not_to(change { Authentication.count })
      end.not_to(change { Account.count })
      expect(result.award.save).to eq(true)
    end
  end

  context 'when the uid is missing' do
    it 'fails' do
      result = described_class.call(
        award: award,
        channel_id: project.channels.first.id
      )
      expect(result).not_to be_success
    end
  end

  context "when the auth doesn't exist yet" do
    context 'when the account exists already in the db' do
      it 'creates the auth, and returns the award' do
        recipient
        stub_request(:post, 'https://slack.com/api/users.info')
          .with(body: { 'token' => 'slack token', 'user' => 'U99M9QYFQ_other' },
                headers: { 'Accept' => 'application/json; charset=utf-8', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Slack Ruby Client/0.11.0' })
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'users_info_response.json')), headers: {})

        result = nil
        expect do
          expect do
            expect do
              result = described_class.call(
                award: award,
                channel_id: project.channels.first.id,
                uid: 'U99M9QYFQ_other'
              )
              expect(result.message).to be_nil
              expect(result.award.award_type).to eq(award_type)
              expect(result.award.save).to eq(true)
            end.not_to(change { Award.count })
          end.to(change { Authentication.count }.by(1))
        end
      end
    end
  end

  context "when the account doesn't exist yet" do
    before do
      stub_request(:post, 'https://slack.com/api/users.info')
        .with(body: { 'token' => 'slack token', 'user' => 'U99M9QYFQ' })
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'users_info_response.json')), headers: {})
        recipient.destroy
    end

    it 'creates the auth with the slack details from the project' do
      expect do
        result = described_class.call(
          award: award,
          channel_id: project.channels.first.id,
          uid: 'U99M9QYFQ'
        )
        expect(result.message).to be_nil
      end.to(change { Authentication.count }.by(1))
      created_account = Account.last
      expect(created_account.teams.last).to eq team
    end

    it 'fetches the user from slack and creates the account, auth, and returns the award' do
      result = nil
      expect do
        expect do
          result = described_class.call(
            award: award,
            channel_id: project.channels.first.id,
            uid: 'U99M9QYFQ'
          )
          expect(result.message).to be_nil
          expect(result.award.award_type).to eq(award_type)
          expect(result.award.account).to eq(Account.last)
        end.not_to(change { Award.count })
      end.to(change { Account.count }.by(1))
      expect(result.award.save).to eq(true)
    end

    it 'create the account, auth, and for discord returns the award' do
      stub_discord_channels
      channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'discord_channel')
      result = nil
      stub_discord_user
      expect do
        expect do
          result = described_class.call(
            award: award,
            channel_id: channel.id,
            uid: '123445'
          )
          expect(result.message).to be_nil
          expect(result.award.award_type).to eq(award_type)
          expect(result.award.account).to eq(Account.last)
        end.not_to(change { Award.count })
      end.to(change { Account.count }.by(1))
      expect(result.award.save).to eq(true)
    end
  end
end
