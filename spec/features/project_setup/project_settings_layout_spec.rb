require 'rails_helper'

describe 'project settings layout:', js: true do
  let!(:account) { create(:account, first_name: 'Glenn', last_name: 'Spanky', email: 'gleenn@example.com') }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account, public: false) }

  before do
    Capybara.page.current_window.resize_to(1500, 2000) # (width, height)
    login(account)
    visit edit_project_path(project)
  end

  it 'width of window == 1024' do
    Capybara.page.current_window.resize_to(1024, 2000)
    expect(page).to have_link('General Info')
    expect(page).to have_link('Communication Channels')
    expect(page).to have_link('Blockchain Settings')
    expect(page).to have_link('Awards Offered')
    expect(page).to have_link('Visibility')
  end

  it 'width of window < 1024' do
    Capybara.page.current_window.resize_to(100, 2000)
    expect(page).to have_link('General Info')
    expect(page).to have_link('Communication Channels')
    expect(page).to have_link('Blockchain Settings')
    expect(page).to have_link('Awards Offered')
    expect(page).to have_link('Visibility')
  end

  it 'click on \'Visibility\' menu item' do
    click_on_left_menu('Visibility', 'visibility')
  end

  it 'click on \'Communication Channels\' menu item' do
    click_on_left_menu('Visibility', 'visibility')
    click_on_left_menu('Communication Channels', 'communication-channels')
  end

  it 'click on \'General Info\' menu item' do
    click_on_left_menu('Visibility', 'visibility')
    click_on_left_menu('General Info', 'general-info')
  end

  it 'click on \'Awards Offered\' menu item' do
    click_on_left_menu('Awards Offered', 'awards-offered')
  end

  it 'click on \'Blockchain Settings\' menu item' do
    click_on_left_menu('Blockchain Settings', 'contribution-terms')
  end
end

def click_on_left_menu(link_text, anchor)
  expect(page.evaluate_script("$('.content-box[data-id=#{anchor}]').visible()")).to be false
  click_link link_text
  sleep 2
  expect(page.evaluate_script("$('.content-box[data-id=#{anchor}]').visible()")).to be true
end
