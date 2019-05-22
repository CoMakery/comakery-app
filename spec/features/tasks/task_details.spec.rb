require 'rails_helper'

describe 'task details page', :js do
  let!(:ready_task) { create(:award, status: 'ready') }
  let!(:started_task) { create(:award, status: 'started') }
  let!(:submitted_task_to_accept) { create(:award, status: 'submitted') }
  let!(:submitted_task_to_reject) { create(:award, status: 'submitted') }

  it 'allows a contributor to start an available task' do
    login(ready_task.account)
    visit(project_award_type_award_path(ready_task.project, ready_task.award_type, ready_task))
    expect(page).to have_content 'TASK DETAILS'
    expect(page).to have_content 'WHAT IS THE EXPECTED BENEFIT'
    expect(page).to have_content 'DESCRIPTION'
    expect(page).to have_content 'ACCEPTANCE CRITERIAS'
    find_button('start task').click
    expect(page).to have_content 'TASK STARTED'
  end

  it 'allows a contributor to submit a started task for review' do
    login(started_task.account)
    visit(project_award_type_award_path(started_task.project, started_task.award_type, started_task))
    expect(page).to have_content 'TASK DETAILS'
    expect(page).to have_content 'TASK SUBMISSION'
    expect(page).to have_content 'URL WHERE COMPLETED WORK CAN BE VIEWED'
    expect(page).to have_content 'ADDITIONAL COMMENTS'
    fill_in 'task[submission_url]', with: 'http://comakery.com'
    fill_in 'task[submission_comment]', with: 'Hello'
    find_button('submit task').click
    expect(page).to have_content 'TASK SUBMITTED'
  end

  it 'allows a project owner to review and accept a submitted task' do
    login(submitted_task_to_accept.issuer)
    visit(project_award_type_award_path(submitted_task_to_accept.project, submitted_task_to_accept.award_type, submitted_task_to_accept))
    expect(page).to have_content 'TASK DETAILS'
    expect(page).to have_content 'SUBMITTED WORK'
    expect(page).to have_content 'URL WHERE COMPLETED WORK CAN BE VIEWED'
    expect(page).to have_content 'ADDITIONAL COMMENTS'
    find_button('accept').click
    expect(page).to have_content 'TASK ACCEPTED'
  end

  it 'allows a project owner to review and reject a submitted task' do
    login(submitted_task_to_reject.issuer)
    visit(project_award_type_award_path(submitted_task_to_reject.project, submitted_task_to_reject.award_type, submitted_task_to_reject))
    find_button('reject & end').click
    expect(page).to have_content 'TASK REJECTED'
  end
end
