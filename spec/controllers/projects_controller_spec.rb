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
      expect(assigns[:private_projects].map(&:title)).to match_array(["my_private_project", "my_public_project"])
      expect(assigns[:public_projects].map(&:title)).to match_array(["other_public_project"])
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
    context "when slack returns successful api calls" do
      before do
        expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: ["foo", "bar"]))
      end

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

        expect(assigns[:slack_channels]).to eq(["foo", "bar"])
      end
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
              slack_channel: "slack_channel",
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
      expect(project.slack_channel).to eq("slack_channel")
      expect(project.slack_team_id).to eq(account.authentications.first.slack_team_id)
      expect(project.slack_team_name).to eq(account.authentications.first.slack_team_name)
    end

    it "when valid, re-renders with errors" do
      expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: ["foo", "bar"]))

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
    let!(:cat_project) { create(:project, title: "Cats", description: "Cats with lazers", owner_account: account, slack_team_id: 'foo') }
    let!(:dog_project) { create(:project, title: "Dogs", description: "Dogs with donuts", owner_account: account, slack_team_id: 'foo') }
    let!(:yak_project) { create(:project, title: "Yaks", description: "Yaks with parser generaters", owner_account: account, slack_team_id: 'foo') }
    let!(:fox_project) { create(:project, title: "Foxes", description: "Foxes with boxes", owner_account: account, slack_team_id: 'foo') }

    describe "#index" do
      let!(:cat_project_award) { create(:award, award_type: create(:award_type, project: cat_project), created_at: 2.days.ago) }
      let!(:dog_project_award) { create(:award, award_type: create(:award_type, project: dog_project), created_at: 1.days.ago) }
      let!(:yak_project_award) { create(:award, award_type: create(:award_type, project: yak_project), created_at: 3.days.ago) }

      include ActionView::Helpers::DateHelper
      it "lists the projects ordered by most recent award date desc" do

        get :index

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(["Dogs", "Cats", "Yaks", "Foxes"])
        expect(assigns[:projects].map { |p| time_ago_in_words(p.last_award_created_at) if p.last_award_created_at }).to eq(["1 day", "2 days", "3 days", nil])
      end

      it "allows querying based on the titleof the project, ignoring case" do
        get :index, query: "cats"

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(["Cats"])
      end

      it "allows querying based on the title or description of the project, ignoring case" do
        get :index, query: "o"

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(["Dogs", "Foxes"])
      end
    end

    describe "#edit" do
      before do
        expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: ["foo", "bar"]))
      end

      it "works" do
        get :edit, id: cat_project.to_param

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(cat_project)
        expect(assigns[:slack_channels]).to eq(["foo", "bar"])
      end
    end

    describe "#update" do
      it "updates a project" do
        small_award_type = cat_project.award_types.create!(name: "Small Award", amount: 100)
        medium_award_type = cat_project.award_types.create!(name: "Medium Award", amount: 300)
        destroy_me_award_type = cat_project.award_types.create!(name: "Destroy Me Award", amount: 300)

        expect do
          expect do
            put :update, id: cat_project.to_param,
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
        cat_project.reload
        expect(cat_project.title).to eq("updated Project title here")
        expect(cat_project.description).to eq("updated Project description here")
        expect(cat_project.tracker).to eq("http://github.com/here/is/my/tracker/updated")

        award_types = cat_project.award_types.order(:amount)
        expect(award_types.size).to eq(3)
        expect(award_types.first.name).to eq("Small Award")
        expect(award_types.first.amount).to eq(150)
        expect(award_types.second.name).to eq("Medium Award")
        expect(award_types.second.amount).to eq(300)
        expect(award_types.third.name).to eq("Big Award")
        expect(award_types.third.amount).to eq(500)
      end

      it "re-renders with errors when updating fails" do
        expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: ["foo", "bar"]))

        small_award_type = cat_project.award_types.create!(name: "Small Award", amount: 100)
        medium_award_type = cat_project.award_types.create!(name: "Medium Award", amount: 300)
        destroy_me_award_type = cat_project.award_types.create!(name: "Destroy Me Award", amount: 400)

        expect do
          expect do
            put :update, id: cat_project.to_param,
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
        expect(assigns[:slack_channels]).to eq(["foo", "bar"])


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
      it "allows team members to view projects and assigns awardable accounts from slack api and db and de-dups" do
        expect(GetAwardableAccounts).to receive(:call).and_return(double(awardable_accounts: []))
        expect(GetAwardData).to receive(:call).and_return(double(award_data: {contributions: [], award_amounts: {my_project_coins: 0, total_coins_issued: 0}}))

        get :show, id: cat_project.to_param

        expect(response.code).to eq "200"
        expect(assigns(:project)).to eq cat_project
        expect(assigns[:award]).to be_new_record
        expect(assigns[:awardable_accounts]).to eq([])
        expect(assigns[:award_data]).to eq({:contributions => [], :award_amounts => {:my_project_coins => 0, :total_coins_issued => 0}})
      end

      it "only denies non-owners to view projects" do
        cat_project.update(slack_team_id: "some other team")

        get :show, id: cat_project.to_param

        expect(response.code).to eq "302"
        expect(assigns(:project)).to eq cat_project
      end
    end
  end
end
