require 'rails_helper'

describe Authentication do
  describe ".find_or_create_from_auth_hash" do
    let(:auth_hash) {
      {
          'provider' => "slack",
          'uid' => "this is a uid",
          'extra' => {'user_info' => {'user' => {'profile' => {'email' => "bob@example.com"}}}}
      }
    }

    context "when no account exists yet" do
      it "creates an account and authentications for that account" do
        account = Authentication.find_or_create_from_auth_hash(auth_hash)

        expect(account.email).to eq("bob@example.com")
        expect(account.authentications.first.provider).to eq("slack")
        expect(account.authentications.first.uid).to eq("this is a uid")
      end
    end

    context "when there is a related account" do
      let!(:account) { create(:account, email: 'bob@example.com') }
      let!(:authentication) { create(:authentication, account_id: account.id, uid: "this is a uid", provider: "slack") }

      it "returns the existing account" do
        result = nil
        expect do
          expect do
            result = Authentication.find_or_create_from_auth_hash(auth_hash)
          end.not_to change { Account.count }
        end.not_to change { Authentication.count }

        expect(result.id).to eq(account.id)
      end
    end
  end
end
