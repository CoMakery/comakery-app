require "rails_helper"

describe ProjectsController do
  let(:project) { create :project }

  before do
    login
  end

  describe "#new" do
    it "works" do
      get :new

      expect(response.status).to eq(200)
    end
  end

  describe "#create" do
    it "creates a project" do
      expect do
        post :create, project: {title: "Project title here", description: "Project description here"}
        expect(response.status).to eq(302)
      end.to change { Project.count }.by(1)

      project = Project.last
      expect(project.title).to eq("Project title here")
      expect(project.description).to eq("Project description here")
    end
  end

  describe "#show" do
    specify do
      get :show, id: project.to_param

      expect(response.code).to eq "200"
      expect(assigns(:project)).to eq project
    end
  end
end
