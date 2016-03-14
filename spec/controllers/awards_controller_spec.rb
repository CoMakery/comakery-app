require 'rails_helper'

describe AwardsController do
  let!(:issuer) { create(:account, email: "issuer@example.com").tap { |a| create(:authentication, slack_team_id: "foo", account: a, slack_user_id: 'issuer id') } }
  let!(:receiver_account) { create(:account, email: "receiver@example.com").tap { |a| create(:authentication, slack_first_name: "Rece", slack_last_name: "Iver", slack_team_id: "foo", slack_user_name: 'receiver', slack_user_id: 'receiver id', account: a) } }
  let!(:other_account) { create(:account, email: "other@example.com").tap { |a| create(:authentication, slack_team_id: "foo", account: a, slack_user_id: 'other id') } }
  let!(:different_team_account) { create(:account, email: "different@example.com").tap { |a| create(:authentication, slack_team_id: "bar", account: a, slack_user_id: 'different team member id') } }

  let(:project) { create(:project, owner_account: issuer, slack_team_id: "foo", public: false) }

  describe "#index" do
    let!(:award) { create(:award, award_type: create(:award_type, project: project), account: other_account, issuer: issuer) }
    let!(:different_project_award) { create(:award, award_type: create(:award_type, project: create(:project)), account: other_account, issuer: issuer) }

    context "when logged in" do
      before { login(issuer) }

      it "shows awards for current project" do
        get :index, project_id: project.to_param

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(project)
        expect(assigns[:awards]).to match_array([award])
      end
    end

    context "when logged out" do
      context "with a public project" do
        let!(:public_project) { create(:project, owner_account: issuer, slack_team_id: "foo", public: true) }
        let!(:public_award) { create(:award, award_type: create(:award_type, project: public_project)) }

        it "shows awards for public projects" do
          get :index, project_id: public_project.to_param

          expect(response.status).to eq(200)
          expect(assigns[:project]).to eq(public_project)
          expect(assigns[:awards]).to match_array([public_award])
        end
      end

      context "with a private project" do
        let!(:private_project) { create(:project, owner_account: issuer, slack_team_id: "foo", public: false) }
        let!(:private_award) { create(:award, award_type: create(:award_type, project: private_project)) }

        it "sends you away" do
          get :index, project_id: private_project.to_param

          expect(response.status).to eq(302)
          expect(response).to redirect_to("/404.html")
        end
      end
    end
  end

  describe "#create" do
    let(:award_type) { create(:award_type, project: project) }

    before { login(issuer) }

    context "logged in" do
      it "records a award being created" do
        request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

        expect_any_instance_of(Account).to receive(:send_award_notifications)
        expect do
          post :create, project_id: project.to_param, award: {
              slack_user_id: receiver_account.slack_auth.slack_user_id,
              award_type_id: award_type.to_param,
              description: "This rocks!!11"
          }
          expect(response.status).to eq(302)
        end.to change { project.awards.count }.by(1)

        expect(response).to redirect_to(project_path(project))
        expect(flash[:notice]).to eq("Successfully sent award to Rece Iver")

        award = Award.last
        expect(award.award_type).to eq(award_type)
        expect(award.account).to eq(receiver_account)
        expect(award.issuer).to eq(issuer)
        expect(award.description).to eq("This rocks!!11")
      end

      it "renders error if you specify a award type that doesn't belong to a project" do
        expect_any_instance_of(Account).not_to receive(:send_award_notifications)
        request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

        expect do
          post :create, project_id: project.to_param, award: {
              slack_user_id: "receiver id",
              award_type_id: create(:award_type, amount: 1000000000, project: create(:project, slack_team_id: "hackerz")).to_param,
              description: "I am teh haxor"
          }
          expect(response.status).to eq(302)
        end.not_to change { project.awards.count }
        expect(flash[:error]).to eq("Failed sending award - Not authorized")
      end

      it "renders error if you specify a slack user id that doesn't belong to a project" do
        expect_any_instance_of(Account).not_to receive(:send_award_notifications)
        request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

        expect do
          post :create, project_id: project.to_param, award: {
              slack_user_id: 'different team member id',
              award_type_id: award_type.to_param,
              description: "I am teh haxor"
          }
          expect(response.status).to eq(302)
        end.not_to change { project.awards.count }
        expect(flash[:error]).to eq("Failed sending award - Not authorized")
      end

      it "redirects back to projects show if error saving" do
        expect do
          request.env["HTTP_REFERER"] = "/projects/#{project.to_param}"

          post :create, project_id: project.to_param, award: {
              slack_user_id: receiver_account.slack_auth.slack_user_id,
              description: "This rocks!!11"
          }
          expect(response.status).to eq(302)
        end.not_to change { project.awards.count }

        expect(response).to redirect_to(project_path(project))
        expect(flash[:error]).to eq("Failed sending award - Award type can't be blank")
      end
    end
  end
end
