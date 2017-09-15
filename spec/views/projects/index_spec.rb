require 'rails_helper'

describe 'projects/index.html.rb' do
  before do
    project = create(:project, description: 'markdown _rocks_ **hard**: www.auto.link')
    assign :projects, Project.with_last_activity_at.decorate
    assign :project_contributors, project => []
    allow(view).to receive(:current_account).and_return(nil)
    allow(view).to receive(:policy).and_return(double('project policy', new?: false))
  end

  describe 'Project description' do
    it 'renders mardown as plain text' do
      render
      assert_select '.description', html: /markdown rocks hard: www.auto.link/
    end
  end
end
