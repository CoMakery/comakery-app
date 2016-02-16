require "rails_helper"

describe "editing a project" do
  let(:project) { create :project }

  specify do
    visit project_path(project)
    click_link "Edit project"
  end
end
