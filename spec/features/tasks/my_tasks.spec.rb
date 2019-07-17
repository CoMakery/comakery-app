require 'rails_helper'

describe 'my tasks page', :js do
  let!(:ready_task) { create(:award, status: 'ready') }
  let!(:started_task) { create(:award, status: 'started') }
  let!(:submitted_task) { create(:award, status: 'submitted') }
  let!(:accepted_task) { create(:award, status: 'accepted') }
  let!(:paid_task) { create(:award, status: 'paid') }

  before do
    ENV['DEFAULT_PROJECT_ID'] = create(:project).id.to_s
    create(:experience, account: ready_task.account)
  end

  it 'has link to past awards' do
    login(ready_task.account)
    visit(my_tasks_path)
    expect(page).to have_link(href: show_account_path)
  end

  it 'has project filtering feature for ready tasks' do
    login(ready_task.account)
    visit(my_tasks_path)
    find_link(href: /project_id=/).click
    expect(page).to have_content 'FILTERED BY PROJECT'
  end

  it 'shows ready tasks to a contributor' do
    login(ready_task.account)
    visit(my_tasks_path)
    expect(page).to have_content ready_task.name.upcase
    expect(page).to have_content ready_task.status.upcase
    expect(page).to have_content ready_task.project.title.upcase
    expect(page).to have_link(href: project_award_type_award_path(ready_task.project, ready_task.award_type, ready_task))
  end

  it 'shows started tasks to a contributor' do
    login(started_task.account)
    visit(my_tasks_path(filter: 'started'))
    expect(page).to have_content started_task.name.upcase
    expect(page).to have_content started_task.status.upcase
    expect(page).to have_content started_task.project.title.upcase
    expect(page).to have_link(href: project_award_type_award_path(started_task.project, started_task.award_type, started_task))
  end

  it 'shows submitted tasks to a contributor' do
    login(submitted_task.account)
    visit(my_tasks_path(filter: 'submitted'))
    expect(page).to have_content submitted_task.name.upcase
    expect(page).to have_content submitted_task.status.upcase
    expect(page).to have_content submitted_task.project.title.upcase
    expect(page).to have_link(href: project_award_type_award_path(submitted_task.project, submitted_task.award_type, submitted_task))
  end

  it 'shows done tasks' do
    login(paid_task.account)
    visit(my_tasks_path(filter: 'done'))
    expect(page).to have_content paid_task.name.upcase
    expect(page).to have_content paid_task.status.upcase
    expect(page).to have_content paid_task.project.title.upcase
    expect(page).to have_link(href: project_award_type_award_path(paid_task.project, paid_task.award_type, paid_task))
  end

  it 'shows tasks available for review to a project owner' do
    login(submitted_task.issuer)
    visit(my_tasks_path(filter: 'to review'))
    expect(page).to have_content submitted_task.name.upcase
    expect(page).to have_content submitted_task.status.upcase
    expect(page).to have_content submitted_task.project.title.upcase
    expect(page).to have_link(href: project_award_type_award_path(submitted_task.project, submitted_task.award_type, submitted_task))
  end

  it 'shows tasks available for payment to a project owner' do
    login(accepted_task.issuer)
    visit(my_tasks_path(filter: 'to pay'))
    expect(page).to have_content accepted_task.name.upcase
    expect(page).to have_content accepted_task.status.upcase
    expect(page).to have_content accepted_task.project.title.upcase
    expect(page).to have_link(href: awards_project_path(accepted_task.project))
  end
end
