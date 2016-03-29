require 'rails_helper'

describe "the dev environment" do
  it "fails if the env has a beta whitelist env var set to anything besides blank" do
    10.times { puts "WARNING!!! - ENV has BETA_SLACK_INSTANCE_WHITELIST set to non-blank" } if ENV["BETA_SLACK_INSTANCE_WHITELIST"].present?
    expect(ENV["BETA_SLACK_INSTANCE_WHITELIST"]).to be_blank
  end
end