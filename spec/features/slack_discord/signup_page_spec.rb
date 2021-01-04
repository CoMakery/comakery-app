require 'rails_helper'

describe 'signup page' do
  specify 'without discord' do
    allow(Comakery::Discord).to receive(:enabled?).and_return(false)

    visit '/accounts/new'

    expect(page).not_to have_content 'Discord'
    expect(page).not_to have_content 'Discord'
  end

  specify 'with discord' do
    allow(Comakery::Discord).to receive(:enabled?).and_return(true)

    visit '/accounts/new'

    expect(page).to have_content 'Discord'
    expect(page).to have_content 'Discord'
  end

  specify 'without slack' do
    allow(Comakery::Slack).to receive(:enabled?).and_return(false)

    visit '/accounts/new'

    expect(page).not_to have_content 'Slack'
    expect(page).not_to have_link 'Slack'
  end

  specify 'with slack' do
    allow(Comakery::Slack).to receive(:enabled?).and_return(true)

    visit '/accounts/new'

    expect(page).to have_content 'Slack'
    expect(page).to have_link 'Slack'
  end
end
