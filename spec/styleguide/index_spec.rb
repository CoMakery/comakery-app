require 'rails_helper'

describe 'styleguide', type: :feature do
  scenario 'index' do
    visit '/dev/styleguide/index.html'
    within('h2') { expect(page.text).to eq('Dashboard') }
  end

  scenario 'accordion' do
    visit '/dev/styleguide/accordion.html'
    expect(page).to have_css('.accordion-item', count: 4)
  end

  scenario 'activity' do
    visit '/dev/styleguide/activity.html'
    within('.divide-y') { expect(page).to have_css('.row', count: 18) }
  end

  scenario 'auth-lock' do
    visit '/dev/styleguide/auth-lock.html'
    within('h2') { expect(page.text).to eq('Account Locked') }
  end

  scenario 'blank' do
    visit '/dev/styleguide/blank.html'
    within('.empty-title') { expect(page.text).to eq('No results found') }
    expect(page).to have_css('.empty-action')
  end

  scenario 'buttons' do
    visit '/dev/styleguide/buttons.html'
    within('.row.row-cards') { expect(page).to have_css('.card', count: 8) }
  end

  scenario 'cards' do
    visit '/dev/styleguide/cards.html'
    expect(page).to have_css('.col-md-6.col-xl-4')
    expect(page).to have_css('.col-md-6.col-xl-8')
  end

  scenario 'cards-masonry' do
    visit '/dev/styleguide/cards-masonry.html'
    within('.row.row-cards') { expect(page).to have_css('.col-sm-6.col-lg-4', count: 11) }
  end

  scenario 'carousel' do
    visit '/dev/styleguide/carousel.html'
    expect(page).to have_css('.carousel.slide', count: 4)
  end

  scenario 'changelog' do
    visit '/dev/styleguide/changelog.html'
    within('.nav.nav-pills.nav-vertical') { expect(page).to have_css('.nav-item', count: 55) }
  end

  scenario 'charts' do
    visit '/dev/styleguide/charts.html'
    within('.row.row-cards') { expect(page).to have_css('.card', count: 24) }
  end

  scenario 'colors' do
    visit '/dev/styleguide/colors.html'
    within('.table.text-center') { expect(page).to have_css('tr', count: 6) }
  end

  scenario 'docs' do
    visit '/dev/styleguide/docs/index.html'
    within('.nav.nav-pills.nav-vertical') { expect(page).to have_css('.nav-item', count: 55) }
  end

  scenario 'dropdowns' do
    visit '/dev/styleguide/dropdowns.html'
    within('.page-body') do
      within('.container-xl') { expect(page).to have_css('.col-sm-6.col-lg-3', count: 4) }
    end
  end

  scenario 'empty' do
    visit '/dev/styleguide/empty.html'
    within('h2') { expect(page.text).to eq('Empty page') }
  end

  scenario 'error404' do
    visit '/dev/styleguide/error-404.html'
    expect(page).to have_content('404')
  end

  scenario 'error500' do
    visit '/dev/styleguide/error-500.html'
    expect(page).to have_content('500')
  end

  scenario 'error-maintenance' do
    visit '/dev/styleguide/error-maintenance.html'
    expect(page).to have_content('Temporarily down for maintenance')
  end
end
