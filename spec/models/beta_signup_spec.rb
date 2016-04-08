# == Schema Information
#
# Table name: beta_signups
#
#  email_address  :string           not null
#  id             :integer          not null, primary key
#  name           :string
#  oauth_response :jsonb
#  opt_in         :boolean          default("false"), not null
#  slack_instance :string
#

require 'rails_helper'

describe BetaSignup do
  describe "validations" do
    it "requires an email address" do
      expect(BetaSignup.new.tap(&:valid?).errors.full_messages).to eq(["Email address can't be blank"])
      expect(BetaSignup.new(email_address: "somethign not an email").tap(&:valid?).errors.full_messages).to eq(["Email address is invalid"])
    end
  end
end
