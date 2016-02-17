require "rails_helper"

describe ProjectsController do
  let!(:project) { create :project }

  before { login }

  describe "#index" do
    it "lists the projects" do
      get :index

      expect(response.status).to eq(200)
      expect(assigns[:projects].to_a).to eq([project])
    end
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
        post :create, project: {title: "Project title here", description: "Project description here", repo: "http://github.com/here/is/my/tracker"}
        expect(response.status).to eq(302)
      end.to change { Project.count }.by(1)

      project = Project.last
      expect(project.title).to eq("Project title here")
      expect(project.description).to eq("Project description here")
      expect(project.repo).to eq("http://github.com/here/is/my/tracker")
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
