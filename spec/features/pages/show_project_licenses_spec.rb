require 'rails_helper'
require 'refile/file_double'
feature 'pages' do

  scenario '#user_agreement' do
    visit root_path
    click_link 'User Agreement'
    expect(page).to have_content 'User Agreement'
  end

  scenario '#prohibited_use' do
    visit root_path
    click_link 'Prohibited Use'
    expect(page).to have_content 'Prohibited Use'
  end

  scenario '#e_sign_disclosure' do
    visit root_path
    click_link 'E-Sign Disclosure'
    expect(page).to have_content 'E-Sign Disclosure'
  end

  scenario '#privacy_policy' do
    visit root_path
    click_link 'Privacy Policy'
    expect(page).to have_content 'Privacy Policy'
  end
end
