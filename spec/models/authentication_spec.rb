require 'rails_helper'

describe Authentication do

  describe ".find_or_create_from_auth_hash" do
    let(:auth_hash) {
      {
          'provider' => 'slack',
          "credentials" => {
              "token" => "xoxp-0000000000-1111111111-22222222222-aaaaaaaaaa"
          },
          'extra' => {'user_info' => {'user' => {'profile' => {'email' => 'bob@example.com'}}}},
          'info' => {
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
            end.to raise_error(Authentication::MissingAuthParamException)
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

# {
#     "provider" => "slack",
#     "uid" => "U08M8QYFQ",
#     "info" => {
#         "nickname" => "glenn",
#         "team" => "Citizen Code",
#         "user" => "glenn",
#         "team_id" => "T0366S81P",
#         "user_id" => "U08M8QYFQ",
#         "name" => "Glenn Jahnke",
#         "email" => "glenn@citizencode.io",
#         "first_name" => "Glenn",
#         "last_name" => "Jahnke",
#         "description" => nil,
#         "image_24" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_24.jpg",
#         "image_48" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_48.jpg",
#         "image" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_192.jpg",
#         "team_domain" => "citizencode",
#         "is_admin" => false,
#         "is_owner" => false,
#         "time_zone" => "America/Los_Angeles"
#     },
#     "credentials" => {
#         "token" => "xoxp-3210892057-8722848534-21820876805-a4c2d4614e",
#         "expires" => false
#     },
#     "extra" => {
#         "raw_info" => {
#             "ok" => true,
#             "url" => "https://citizencode.slack.com/",
#             "team" => "Citizen Code",
#             "user" => "glenn",
#             "team_id" => "T0366S81P",
#             "user_id" => "U08M8QYFQ"
#         },
#         "web_hook_info" => {},
#         "bot_info" => {},
#         "user_info" => {
#             "ok" => true,
#             "user" => {
#                 "id" => "U08M8QYFQ",
#                 "team_id" => "T0366S81P",
#                 "name" => "glenn",
#                 "deleted" => false,
#                 "status" => nil,
#                 "color" => "b14cbc",
#                 "real_name" => "Glenn Jahnke",
#                 "tz" => "America/Los_Angeles",
#                 "tz_label" => "Pacific Standard Time",
#                 "tz_offset" => -28800,
#                 "profile" => {
#                     "first_name" => "Glenn",
#                     "last_name" => "Jahnke",
#                     "image_24" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_24.jpg",
#                     "image_32" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_32.jpg",
#                     "image_48" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_48.jpg",
#                     "image_72" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_72.jpg",
#                     "image_192" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_192.jpg",
#                     "image_original" => "https://avatars.slack-edge.com/2015-08-12/9040580855_da7594e03c0818d7b9ae_original.jpg",
#                     "real_name" => "Glenn Jahnke",
#                     "real_name_normalized" => "Glenn Jahnke",
#                     "email" => "glenn@citizencode.io"
#                 },
#                 "is_admin" => false,
#                 "is_owner" => false,
#                 "is_primary_owner" => false,
#                 "is_restricted" => false,
#                 "is_ultra_restricted" => false,
#                 "is_bot" => false,
#                 "has_2fa" => false
#             }
#         },
#         "team_info" => {
#             "ok" => true,
#             "team" => {
#                 "id" => "T0366S81P",
#                 "name" => "Citizen Code",
#                 "domain" => "citizencode",
#                 "email_domain" => "citizencode.io",
#                 "icon" => {
#                     "image_34" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_34.jpg",
#                     "image_44" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_44.jpg",
#                     "image_68" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_68.jpg",
#                     "image_88" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_88.jpg",
#                     "image_102" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_102.jpg",
#                     "image_132" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_132.jpg",
#                     "image_original" => "https://s3-us-west-2.amazonaws.com/slack-files2/avatars/2015-03-13/4044640949_be1b32f3b1f69debbcc6_original.jpg"
#                 }
#             }
#         }
#     }
# }
