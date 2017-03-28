require 'rails_helper'

describe "shared/_award_progress_bar.html.rb" do
  let(:account) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "catlazer", slack_team_domain: "catlazerdomain", slack_team_name: "Cat Lazer", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_team_image_132_url: "https://slack.example.com/awesome-team-image-132-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Glenn", slack_last_name: "Spanky") } }

  let(:other_team_account) { create(:account, email: "bob@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "doglazer", slack_team_domain: "doglazerdomain", slack_team_name: "Dog Lazer", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_team_image_132_url: "https://slack.example.com/awesome-team-image-132-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Bob", slack_last_name: "Junior") } }

  let(:project) { create(:project,
                         title: "Cats with Lazers Project",
                         description: "cats with lazers",
                         owner_account: account,
                         slack_team_id: "catlazer",
                         public: false,
  payment_type: :revenue_share) }



  describe 'with no auth' do
    before do
      assign :current_user, nil
      assign :project, project.decorate
      assign :current_auth, nil
      render
    end

    specify { expect(rendered).to eq("") }
  end

  describe 'with current auth from another slack team' do

    before do
      view.stub(:current_user) { other_team_account }

      assign :project, project.decorate
      assign :current_auth, other_team_account.slack_auth.decorate
      render
    end

    specify { expect(rendered).to eq("") }
  end

  describe 'with current auth from the project slack team' do


    before do
      view.stub(:current_user) { account }

      assign :project, project.decorate
      assign :current_auth, account.slack_auth.decorate
      render
    end

    specify { expect(rendered).to have_css(".meter-box") }
  end
end