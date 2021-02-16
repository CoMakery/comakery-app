require 'rails_helper'

describe 'login page' do
  specify 'without discord' do
    allow(Comakery::Discord).to receive(:enabled?).and_return(false)

    visit '/session/new'

    expect(page).not_to have_content 'Discord'
    expect(page).not_to have_link 'Discord'
  end

  specify 'with discord' do
    allow(Comakery::Discord).to receive(:enabled?).and_return(true)

    visit '/session/new'

    expect(page).to have_content 'Discord'
    expect(page).to have_button 'Discord'
  end

  specify 'without slack' do
    allow(Comakery::Slack).to receive(:enabled?).and_return(false)

    visit '/session/new'

    expect(page).not_to have_content 'Slack'
    expect(page).not_to have_button 'Slack'
  end

  specify 'with slack' do
    allow(Comakery::Slack).to receive(:enabled?).and_return(true)

    visit '/session/new'

    expect(page).to have_content 'Slack'
    expect(page).to have_button 'Slack'
  end
end
