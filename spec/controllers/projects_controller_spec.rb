require "rails_helper"

describe ProjectsController do
  let!(:account) { create(:account, email: 'account@example.com').tap { |a| create(:authentication, account: a, slack_team_id: "foo", slack_user_name: "account", slack_user_id: "account slack_user_id", slack_team_domain: "foobar") } }

  before { login(account) }

  describe "#landing" do
    let!(:other_public_project) { create(:project, slack_team_id: "somebody else", public: true, title: "other_public_project") }
    let!(:other_private_project) { create(:project, slack_team_id: "somebody else", public: false, title: "other_private_project") }
    let!(:my_private_project) { create(:project, slack_team_id: "foo", title: "my_private_project") }
    let!(:my_public_project) { create(:project, slack_team_id: "foo", public: true, title: "my_public_project") }

    it "returns your private projects, and public projects that *do not* belong to you" do
      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:private_projects].map(&:title)).to eq(["my_private_project", "my_public_project"])
      expect(assigns[:public_projects].map(&:title)).to eq(["other_public_project"])
    end

    it "renders nicely even if you are not logged in" do
      logout

      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:private_projects].map(&:title)).to eq([])
      expect(assigns[:public_projects].map(&:title)).to match_array(["my_public_project", "other_public_project"])
    end
  end

  describe "#new" do
    it "works" do
      get :new

      expect(response.status).to eq(200)
      expect(assigns[:project]).to be_a_new_record
      expect(assigns[:project]).to be_public
      expect(assigns[:project].award_types.size).to eq(3)

      expect(assigns[:project].award_types.first).to be_a_new_record
      expect(assigns[:project].award_types.first.name).to eq("Thanks")
      expect(assigns[:project].award_types.first.amount).to eq(10)

      expect(assigns[:project].award_types.second).to be_a_new_record
      expect(assigns[:project].award_types.second.name).to eq("Small Contribution")
      expect(assigns[:project].award_types.second.amount).to eq(100)

      expect(assigns[:project].award_types.third).to be_a_new_record
      expect(assigns[:project].award_types.third.name).to eq("Contribution")
      expect(assigns[:project].award_types.third.amount).to eq(1000)
    end
  end

  describe "#create" do
    it "when valid, creates a project and associates it with the current account" do
      expect do
        expect do
          post :create, project: {
                          title: "Project title here",
                          description: "Project description here",
                          image: fixture_file_upload("helmet_cat.png", 'image/png', :binary),
                          tracker: "http://github.com/here/is/my/tracker",
                          award_types_attributes: [
                              {name: "Small Award", amount: 1000},
                              {name: "Big Award", amount: 2000},
                              {name: "", amount: ""},
                          ]
                      }
          expect(response.status).to eq(302)
        end.to change { Project.count }.by(1)
      end.to change { AwardType.count }.by(2)

      project = Project.last
      expect(project.title).to eq("Project title here")
      expect(project.description).to eq("Project description here")
      expect(project.image).to be_a(Refile::File)
      expect(project.tracker).to eq("http://github.com/here/is/my/tracker")
      expect(project.award_types.first.name).to eq("Small Award")
      expect(project.owner_account_id).to eq(account.id)
      expect(project.slack_team_id).to eq(account.authentications.first.slack_team_id)
      expect(project.slack_team_name).to eq(account.authentications.first.slack_team_name)
    end

    it "when valid, re-renders with errors" do
      expect do
        expect do
          post :create, project: {
                          # title: "Project title here",
                          description: "Project description here",
                          image: fixture_file_upload("helmet_cat.png", 'image/png', :binary),
                          tracker: "http://github.com/here/is/my/tracker",
                          award_types_attributes: [
                              {name: "Small Award", amount: 1000},
                              {name: "Big Award", amount: 2000},
                              {name: "", amount: ""},
                          ]
                      }
          expect(response.status).to eq(200)
        end.not_to change { Project.count }
      end.not_to change { AwardType.count }

      expect(flash[:error]).to eq("Project saving failed, please correct the errors below")
      project = assigns[:project]

      expect(project.description).to eq("Project description here")
      expect(project.image).to be_a(Refile::File)
      expect(project.tracker).to eq("http://github.com/here/is/my/tracker")
      expect(project.award_types.first.name).to eq("Small Award")
      expect(project.owner_account_id).to eq(account.id)

      account_slack_auth = account.authentications.first

      expect(project.slack_team_id).to eq(account_slack_auth.slack_team_id)
      expect(project.slack_team_name).to eq(account_slack_auth.slack_team_name)
      expect(project.slack_team_domain).to eq("foobar")
      expect(project.award_types.size).to eq(2)
    end
  end

  context "with a project" do
    let!(:project) { create(:project, title: "Cats", owner_account: account, slack_team_id: 'foo') }

    describe "#index" do
      it "lists the projects" do
        get :index

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(["Cats"])
      end
    end

    describe "#edit" do
      it "works" do
        get :edit, id: project.to_param

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(project)
      end
    end

    describe "#update" do
      it "updates a project" do
        small_award_type = project.award_types.create!(name: "Small Award", amount: 100)
        medium_award_type = project.award_types.create!(name: "Medium Award", amount: 300)
        destroy_me_award_type = project.award_types.create!(name: "Destroy Me Award", amount: 300)

        expect do
          expect do
            put :update, id: project.to_param,
                project: {
                    title: "updated Project title here",
                    description: "updated Project description here",
                    tracker: "http://github.com/here/is/my/tracker/updated",
                    award_types_attributes: [
                        {id: small_award_type.to_param, name: "Small Award", amount: 150},
                        {id: destroy_me_award_type.to_param, _destroy: true},
                        {name: "Big Award", amount: 500},
                    ]
                }
            expect(response.status).to eq(302)
          end.to change { Project.count }.by(0)
        end.to change { AwardType.count }.by(0) # +1 and -1

        expect(flash[:notice]).to eq("Project updated")
        project.reload
        expect(project.title).to eq("updated Project title here")
        expect(project.description).to eq("updated Project description here")
        expect(project.tracker).to eq("http://github.com/here/is/my/tracker/updated")

        award_types = project.award_types.order(:amount)
        expect(award_types.size).to eq(3)
        expect(award_types.first.name).to eq("Small Award")
        expect(award_types.first.amount).to eq(150)
        expect(award_types.second.name).to eq("Medium Award")
        expect(award_types.second.amount).to eq(300)
        expect(award_types.third.name).to eq("Big Award")
        expect(award_types.third.amount).to eq(500)
      end

      it "re-renders with errors when updating fails" do
        small_award_type = project.award_types.create!(name: "Small Award", amount: 100)
        medium_award_type = project.award_types.create!(name: "Medium Award", amount: 300)
        destroy_me_award_type = project.award_types.create!(name: "Destroy Me Award", amount: 400)

        expect do
          expect do
            put :update, id: project.to_param,
                project: {
                    title: "",
                    description: "updated Project description here",
                    tracker: "http://github.com/here/is/my/tracker/updated",
                    award_types_attributes: [
                        {id: small_award_type.to_param, name: "Small Award", amount: 150},
                        {id: destroy_me_award_type.to_param, _destroy: true},
                        {name: "Big Award", amount: 500},
                    ]
                }
            expect(response.status).to eq(200)
          end.not_to change { Project.count }
        end.not_to change { AwardType.count }

        project = assigns[:project]
        expect(flash[:error]).to eq("Project updating failed, please correct the errors below")
        expect(project.title).to eq("")
        expect(project.description).to eq("updated Project description here")
        expect(project.tracker).to eq("http://github.com/here/is/my/tracker/updated")

        award_types = project.award_types.sort_by(&:amount)
        expect(award_types.size).to eq(4)
        expect(award_types.first.name).to eq("Small Award")
        expect(award_types.first.amount).to eq(150)
        expect(award_types.second.name).to eq("Medium Award")
        expect(award_types.second.amount).to eq(300)
        expect(award_types.third.name).to eq("Destroy Me Award")
        expect(award_types.third.amount).to eq(400)
        expect(award_types.fourth.name).to eq("Big Award")
        expect(award_types.fourth.amount).to eq(500)
      end
    end

    describe "#show" do
      let!(:receiver_account) { create(:account, email: "receiver@example.com").tap { |a| create(:authentication, slack_user_id: "U8888UVMH", slack_team_id: "foo", account: a, slack_user_name: "receiver",  slack_first_name: nil, slack_last_name: nil) } }
      let!(:other_account) { create(:account, email: "other@example.com").tap { |a| create(:authentication, slack_user_id: "other id", slack_team_id: "foo", account: a, slack_user_name: "other", slack_first_name: "Other", slack_last_name: "Other") } }
      let!(:different_team_account) { create(:account, email: "different@example.com").tap { |a| create(:authentication, slack_team_id: "bar", account: a, slack_user_name: "differentteam") } }

      let!(:award_type1) { create(:award_type, project: project, amount: 1000, name: "Small Award")}
      let!(:award_type2) { create(:award_type, project: project, amount: 2000, name: "Medium Award")}
      let!(:award_type3) { create(:award_type, project: project, amount: 3000, name: "Big Award")}

      let!(:award1) { create(:award, award_type: award_type1, account: receiver_account)}
      let!(:award2) { create(:award, award_type: award_type2, account: receiver_account)}
      let!(:award3) { create(:award, award_type: award_type3, account: receiver_account)}
      let!(:award4) { create(:award, award_type: award_type1, account: other_account)}
      let!(:award5) { create(:award, award_type: award_type2, account: other_account)}

      it "allows team members to view projects and assigns awardable accounts from slack api and db and de-dups" do
        slack_double = double("slack")
        expect(Swarmbot::Slack).to receive(:get).and_return(slack_double)
        expect(slack_double).to receive(:get_users).and_return([{"id": "U9999UVMH",
                                                                 "team_id": "foo",
                                                                 "name": "bobjohnson",
                                                                 "profile": {"email": "bobjohnson@example.com"}
                                                                },
                                                                {"id": "U8888UVMH",
                                                                 "team_id": "foo",
                                                                 "name": "receiver",
                                                                 "profile": {"email": "receiver@example.com"}
                                                                }])

        get :show, id: project.to_param

        expect(response.code).to eq "200"
        expect(assigns(:project)).to eq project
        expect(assigns[:award]).to be_new_record
        expect(assigns[:awardable_accounts].sort).to match_array([["John Doe - @account", "account slack_user_id"],
                                                                   ["Other Other - @other", "other id"],
                                                                   ["@bobjohnson", "U9999UVMH"],
                                                                   ["@receiver", "U8888UVMH"]])
        expect(assigns[:award_data]).to eq([{"name": "@receiver", "net_amount": 6000}, {"name": "Other Other", "net_amount": 3000}])
      end

      it "only denies non-owners to view projects" do
        project.update(slack_team_id: "some other team")

        get :show, id: project.to_param

        expect(response.code).to eq "302"
        expect(assigns(:project)).to eq project
      end
    end
  end
end
