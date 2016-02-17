require "rails_helper"

describe ProjectsController do
  let(:project) { create :project }

  describe "#show" do
    specify do
      login

      get :show, id: project.to_param

      expect(response.code).to eq "200"
      expect(assigns(:project)).to eq project
    end
  end
end
