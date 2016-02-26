require "rails_helper"

describe ProjectsController do
  let!(:account) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "foo") } }

  before { login(account) }

  describe "#landing" do
    let!(:other_public_project) { create(:project, slack_team_id: "somebody else", public: true, title: "other_public_project") }
    let!(:other_private_project) { create(:project, slack_team_id: "somebody else", public: false, title: "other_private_project") }
    let!(:my_private_project) { create(:project, slack_team_id: "foo", title: "my_private_project") }
    let!(:my_public_project) { create(:project, slack_team_id: "foo", title: "my_public_project") }

    it "returns your private projects, and public projects that *do not* belong to you" do
      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:private_projects].map(&:title)).to eq(["my_private_project", "my_public_project"])
      expect(assigns[:public_projects].map(&:title)).to eq(["other_public_project"])
    end
  end

  describe "#new" do
    it "works" do
      get :new

      expect(response.status).to eq(200)
      expect(assigns[:project]).to be_a_new_record
      expect(assigns[:project]).to be_public
      expect(assigns[:project].reward_types.size).to eq(3)

      expect(assigns[:project].reward_types.first).to be_a_new_record
      expect(assigns[:project].reward_types.first.name).to eq("Thanks")
      expect(assigns[:project].reward_types.first.amount).to eq(10)

      expect(assigns[:project].reward_types.second).to be_a_new_record
      expect(assigns[:project].reward_types.second.name).to eq("Small Contribution")
      expect(assigns[:project].reward_types.second.amount).to eq(100)

      expect(assigns[:project].reward_types.third).to be_a_new_record
      expect(assigns[:project].reward_types.third.name).to eq("Contribution")
      expect(assigns[:project].reward_types.third.amount).to eq(1000)
    end
  end

  describe "#create" do
    it "creates a project and associates it with the current account" do
      expect do
        expect do
          post :create, project: {
                          title: "Project title here",
                          description: "Project description here",
                          image: fixture_file_upload("helmet_cat.png", 'image/png', :binary),
                          tracker: "http://github.com/here/is/my/tracker",
                          reward_types_attributes: [
                              {name: "Small Reward", amount: 1000},
                              {name: "Big Reward", amount: 2000},
                              {name: "", amount: ""},
                          ]
                      }
          expect(response.status).to eq(302)
        end.to change { Project.count }.by(1)
      end.to change { RewardType.count }.by(2)

      project = Project.last
      expect(project.title).to eq("Project title here")
      expect(project.description).to eq("Project description here")
      expect(project.image).to be_a(Refile::File)
      expect(project.tracker).to eq("http://github.com/here/is/my/tracker")
      expect(project.reward_types.first.name).to eq("Small Reward")
      expect(project.owner_account_id).to eq(account.id)
      expect(project.slack_team_id).to eq(account.authentications.first.slack_team_id)
      expect(project.slack_team_name).to eq(account.authentications.first.slack_team_name)
    end
  end

  context "with a project" do
    let!(:project) { create(:project, title: "Cats", owner_account: account) }

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
        small_reward_type = project.reward_types.create!(name: "Small Reward", amount: 100)
        medium_reward_type = project.reward_types.create!(name: "Medium Reward", amount: 300)
        destroy_me_reward_type = project.reward_types.create!(name: "Destroy Me Reward", amount: 300)

        expect do
          expect do
            put :update, id: project.to_param,
                project: {
                    title: "updated Project title here",
                    description: "updated Project description here",
                    tracker: "http://github.com/here/is/my/tracker/updated",
                    reward_types_attributes: [
                        {id: small_reward_type.to_param, name: "Small Reward", amount: 150},
                        {id: destroy_me_reward_type.to_param, _destroy: true},
                        {name: "Big Reward", amount: 500},
                    ]
                }
            expect(response.status).to eq(302)
          end.to change { Project.count }.by(0)
        end.to change { RewardType.count }.by(0) # +1 and -1

        expect(flash[:notice]).to eq("Project updated")
        project.reload
        expect(project.title).to eq("updated Project title here")
        expect(project.description).to eq("updated Project description here")
        expect(project.tracker).to eq("http://github.com/here/is/my/tracker/updated")

        reward_types = project.reward_types.order(:amount)
        expect(reward_types.size).to eq(3)
        expect(reward_types.first.name).to eq("Small Reward")
        expect(reward_types.first.amount).to eq(150)
        expect(reward_types.second.name).to eq("Medium Reward")
        expect(reward_types.second.amount).to eq(300)
        expect(reward_types.third.name).to eq("Big Reward")
        expect(reward_types.third.amount).to eq(500)
      end
    end

    describe "#show" do
      let!(:receiver_account) { create(:account, name: "Receiver").tap { |a| create(:authentication, slack_team_id: "foo", account: a) } }
      let!(:other_account) { create(:account, name: "Other").tap { |a| create(:authentication, slack_team_id: "foo", account: a) } }
      let!(:different_team_account) { create(:account, name: "Other").tap { |a| create(:authentication, slack_team_id: "bar", account: a) } }

      it "allows team members to view projects" do
        get :show, id: project.to_param

        expect(response.code).to eq "200"
        expect(assigns(:project)).to eq project
        expect(assigns[:reward]).to be_new_record
        expect(assigns[:rewardable_accounts].map(&:name).sort).to eq([account.name, other_account.name, receiver_account.name])
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
