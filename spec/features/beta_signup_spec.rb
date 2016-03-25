require 'rails_helper'

describe "Beta signup" do
  # before do
  #   old_env = ENV.to_h
  #   expect(ENV).to(receive(:[])) do |key|
  #     if key == "BETA_SLACK_INSTANCE_WHITELIST"
  #       "comakery"
  #     else
  #       old_env[key]
  #     end
  #   end
  # end

  it "lets users opt in" do
    visit new_beta_signup_path(email_address: "bob@example.com")

    expect(page).to have_content "Sign Up For Free Beta Access"

    expect(page.find("input[name='beta_signup[email_address]']")[:value]).to eq("bob@example.com")
    page.find("input[value='Great, let me know!']").click

    expect(page).to have_content "You have been added to the beta waiting list. Invite more people from your slack to sign up for the beta. We will be inviting the slack teams with the most beta list signups first!"
  end

  it "lets users opt out" do
    visit new_beta_signup_path(email: "bob@example.com")

    expect(page).to have_content "Sign Up For Free Beta Access"

    page.find(:css, "input.opt-out").click

    expect(page).to have_content "You have not been added to the beta waiting list. Check back to see new public CoMakery projects!"
  end
end