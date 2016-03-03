require 'rails_helper'

describe Authentication do
  describe "validations" do
    it "requires many attributes" do
      errors = Authentication.new.tap { |a| a.valid? }.errors.full_messages
      expect(errors).to match_array(["Account can't be blank", "Provider can't be blank", "Slack team name can't be blank", "Slack team name can't be blank", "Slack team can't be blank", "Slack user can't be blank", "Slack user name can't be blank"])
    end
  end

  describe "associations" do
    it "has many projects" do
      project = create(:project)
      expect(create(:authentication, slack_team_id: project.slack_team_id).projects).to match_array([project])
    end
  end

  describe ".find_or_create_from_auth_hash" do
    let(:auth_hash) {
      {
          'provider' => 'slack',
          "credentials" => {
              "token" => "xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa"
          },
          'extra' => {'user_info' => {'user' => {'profile' => {'email' => 'bob@example.com'}}}},
          'info' => {
            'name' => "Bob Roberts",
            'user_id' => 'slack user id',
            'team' => "CoMakery",
            'team_id' => 'slack team id',
            'user' => "bobroberts"
          }
      }
    }

    context "when no account exists yet" do
      it "creates an account and authentications for that account" do
        account = Authentication.find_or_create_from_auth_hash!(auth_hash)

        expect(account.email).to eq("bob@example.com")
        expect(account.authentications.first.provider).to eq("slack")
        expect(account.authentications.first.slack_user_name).to eq("bobroberts")
        expect(account.authentications.first.slack_team_name).to eq("CoMakery")
        expect(account.authentications.first.slack_team_id).to eq("slack team id")
        expect(account.authentications.first.slack_user_id).to eq("slack user id")
        expect(account.authentications.first.slack_token).to eq("xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa")
      end
    end

    context "when there are missing credentials" do
      it "blows up" do
        expect do
          expect do
            expect do
              Authentication.find_or_create_from_auth_hash!({})
            end.to raise_error(SlackAuthHash::MissingAuthParamException)
          end.not_to change { Account.count }
        end.not_to change { Authentication.count }
      end
    end

    context "when there is a related account" do
      let!(:account) { create(:account, email: 'bob@example.com') }
      let!(:authentication) { create(:authentication,
                                     account_id: account.id,
                                     provider: "slack",
                                     slack_user_id: "slack user id",
                                     slack_team_id: "slack team id",
                                     slack_token: "slack token"
      ) }

      it "returns the existing account" do
        result = nil
        expect do
          expect do
            result = Authentication.find_or_create_from_auth_hash!(auth_hash)
          end.not_to change { Account.count }
        end.not_to change { Authentication.count }

        expect(result.id).to eq(account.id)
      end
    end
  end
end
