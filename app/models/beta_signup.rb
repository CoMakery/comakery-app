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

class BetaSignup < ActiveRecord::Base
  validates_presence_of :email_address
  validates_format_of :email_address, with: /\A.*@.*\z/, if: -> { email_address.present? }
end
