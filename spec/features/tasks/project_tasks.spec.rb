require 'rails_helper'

describe 'project page', :js do
  let!(:ready_task) { create(:award, status: 'ready', experience_level: Award::EXPERIENCE_LEVELS['Demonstrated Skills']) }

  before do
    ready_task.project.update(visibility: :public_listed)
  end

  it 'shows ready tasks to a contributor' do
    login(ready_task.account)
    visit(project_path(ready_task.project))
    expect(page).to have_content ready_task.name.upcase
    expect(page).to have_link(href: project_award_type_award_path(ready_task.project, ready_task.award_type, ready_task))
  end

  it 'shows unlock task button to a logged out user which redirects to sign up' do
    visit(project_path(ready_task.project))
    expect(page).to have_content ready_task.name.upcase
    expect(page).to have_link(href: project_award_type_award_start_path(ready_task.project, ready_task.award_type, ready_task))
    find_link('Unlock Task').click
    expect(page).to have_content 'Sign Up'
  end

  it 'shows unlock task button to a contributor with not suitable experience which redirects to my tasks' do
    login(create(:account))
    visit(project_path(ready_task.project))
    expect(page).to have_content ready_task.name.upcase
    expect(page).to have_link(href: project_award_type_award_start_path(ready_task.project, ready_task.award_type, ready_task))
    find_link('Unlock Task').click
    expect(page).to have_content 'TASKS THAT REQUIRE THE'
  end
end
