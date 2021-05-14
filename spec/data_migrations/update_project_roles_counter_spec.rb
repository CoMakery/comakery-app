require 'rails_helper'
require Rails.root.join('db/data_migrations/20210512175535_update_project_roles_counter.rb')

describe UpdateProjectRolesCounter do
  subject { described_class.new.up }

  let(:project) { create(:project) }

  before do
    create(:project_role, project: project)
    create(:project_role, project: project, role: :admin)
    create(:project_role, project: project, role: :observer)
  end

  before { project.update(project_roles_count: 0) }

  it 'updates project roles counter cache' do
    subject

    expect(project.reload.project_roles_count).to eq(4)
  end
end
