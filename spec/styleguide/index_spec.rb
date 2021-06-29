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

  scenario 'forgot-password' do
    visit '/dev/styleguide/forgot-password.html'
    expect(page).to have_content('Forgot password')
    expect(page).to have_selector('input[type="email"]')
  end

  scenario 'form-elements' do
    visit '/dev/styleguide/form-elements.html'
    within('.row.row-cards') do

      expect(page).to have_css('form', count: 3)
    end
  end

  scenario 'gallery' do
    visit '/dev/styleguide/gallery.html'
    within('.row.row-cards') { expect(page).to have_css('img', count: 12) }
  end

  scenario 'icons' do
    visit '/dev/styleguide/icons.html'
    within('.row.row-cards') { expect(page).to have_css('.col-12', count: 3) }
  end

  scenario 'icons-old' do
    visit '/dev/styleguide/icons-old.html'
    within('.row.row-cards') { expect(page).to have_css('.demo-icons-list-wrap', count: 2) }
  end

  xscenario 'inputs' do
    visit '/dev/styleguide/inputs.html'

  end

  scenario 'invoice' do
    visit '/dev/styleguide/invoice.html'
    expect(page).to have_selector(:link_or_button, 'Print Invoice')
  end

  xscenario 'labels' do
    visit '/dev/styleguide/labels.html'

  end

  xscenario 'labels-old' do
    visit '/dev/styleguide/labels-old.html'

  end

  scenario 'layout-combo' do
    visit '/dev/styleguide/layout-combo.html'

    expect(page).to have_css('.navbar.navbar-vertical.navbar-expand-lg.navbar-dark')
  end

  scenario 'layout-condensed' do
    visit '/dev/styleguide/layout-condensed.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-light.d-print-none')
  end

  scenario 'layout-condensed-dark' do
    visit '/dev/styleguide/layout-condensed-dark.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-dark.d-print-none')
  end

  scenario 'layout-dark' do
    visit '/dev/styleguide/layout-dark.html'
    expect(page).to have_css('.antialiased.theme-dark')
  end

  scenario 'layout-fluid' do
    visit '/dev/styleguide/layout-fluid.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-light.d-print-none')
  end

  scenario 'layout-fluid-vertical' do
    visit '/dev/styleguide/layout-fluid-vertical.html'
    expect(page).to have_css('.navbar.navbar-vertical.navbar-expand-lg.navbar-dark')
  end

  scenario 'layout-horizontal' do
    visit '/dev/styleguide/layout-horizontal.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-light.d-print-none')
  end

  scenario 'layout-navbar-dark' do
    visit '/dev/styleguide/layout-navbar-dark.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-dark.d-print-none')
  end

  scenario 'layout-navbar-overlap' do
    visit '/dev/styleguide/layout-navbar-overlap.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-dark.navbar-overlap.d-print-none')
  end

  scenario 'layout-navbar-sticky' do
    visit '/dev/styleguide/layout-navbar-sticky.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-light.sticky-top.d-print-none')
  end

  scenario 'layout-rtl' do
    visit '/dev/styleguide/layout-rtl.html'
    expect(page).to have_css('.navbar.navbar-expand-md.navbar-light.d-print-none')
  end

  scenario 'layout-vertical' do
    visit '/dev/styleguide/layout-vertical.html'
    expect(page).to have_css('.navbar.navbar-vertical.navbar-expand-lg.navbar-dark')
  end

  scenario 'layout-vertical-right' do
    visit '/dev/styleguide/layout-vertical-right.html'
    expect(page).to have_css('.navbar.navbar-vertical.navbar-right.navbar-expand-lg.navbar-light')
  end

  scenario 'layout-vertical-transparent' do
    visit '/dev/styleguide/layout-vertical-transparent.html'
    expect(page).to have_css('.navbar.navbar-vertical.navbar-expand-lg.navbar-transparent')
  end

  scenario 'license' do
    visit '/dev/styleguide/license.html'
    expect(page).to have_content('Tabler License')
  end

  scenario 'lists' do
    visit '/dev/styleguide/lists.html'
    within('.row.row-cards') { expect(page).to have_css('.col-md-6', count: 2) }
  end

  xscenario 'logo' do
    visit '/dev/styleguide/logo.html'

  end

  xscenario 'map-fullsize' do
    visit '/dev/styleguide/map-fullsize.html'

  end

  scenario 'maps' do
    visit '/dev/styleguide/maps.html'
    expect(page).to have_css('#map-simple')
    expect(page).to have_css('#map-light')
  end

  scenario 'markdown' do
    visit '/dev/styleguide/markdown.html'
    expect(page).to have_content('Markdown')
  end

  scenario 'modals' do
    visit '/dev/styleguide/modals.html'
    expect(page).to have_css('.modal.modal-blur.fade', count: 9)
  end

  scenario 'music' do
    visit '/dev/styleguide/music.html'
    within('.col-lg-4') { expect(page).to have_css('.col-md-6.col-lg-12', count: 6) }
  end

  scenario 'navigation' do
    visit '/dev/styleguide/navigation.html'
    within('.box') { expect(page).to have_css('.mb-3', count: 7) }
  end

  scenario 'pagination' do
    visit '/dev/styleguide/pagination.html'
    within('.row.row-cards') { expect(page).to have_css('.pagination', count: 3) }
  end

  scenario 'playground' do
    visit '/dev/styleguide/playground.html'
    within('.page-body') { expect(page).to have_css('.card') }
  end

  scenario 'pricing' do
    visit '/dev/styleguide/pricing.html'
    within('.page-body') { expect(page).to have_css('.col-sm-6.col-lg-3', count: 4) }
  end

  scenario 'search-results' do
    visit '/dev/styleguide/search-results.html'
    within('.page-body') do
      expect(page).to have_css('.col-3', count: 1)
      expect(page).to have_css('.col-9', count: 1)
    end
  end

  scenario 'sign-in' do
    visit '/dev/styleguide/sign-in.html'
    expect(page).to have_content('Login to your account')
  end

  scenario 'sign-up' do
    visit '/dev/styleguide/sign-up.html'
    expect(page).to have_content('Create new account')
  end

  scenario 'skeleton' do
    visit '/dev/styleguide/skeleton.html'
    within('.page-body') do
      expect(page).to have_css('.col-3', count: 5)
      expect(page).to have_css('.col-4', count: 3)
    end
  end

  scenario 'tables' do
    visit '/dev/styleguide/tables.html'
    within('.row.row-cards') { expect(page).to have_css('.col-12', count: 5) }
  end

  xscenario 'tables-old' do
    visit '/dev/styleguide/tables-old.html'
  end

  scenario 'tabs' do
    visit '/dev/styleguide/tabs.html'
    within('.row.row-cards') { expect(page).to have_css('.col-md-4', count: 11) }
  end

  scenario 'terms-of-service' do
    visit '/dev/styleguide/terms-of-service.html'
    expect(page).to have_content('Terms of service')
  end

  scenario 'typography' do
    visit '/dev/styleguide/typography.html'
    expect(page).to have_css('.col-12.markdown')
  end

  xscenario 'ui-components' do
    visit '/dev/styleguide/ui-components.html'
  end

  scenario 'users' do
    visit '/dev/styleguide/users.html'
    within('.row.row-cards') { expect(page).to have_css('.col-md-6.col-lg-3', count: 18) }
  end

  scenario 'widgets' do
    visit '/dev/styleguide/widgets.html'
    within('.page-body') do
      expect(page).to have_css('.col-md-6.col-xl-3', count: 24)
      expect(page).to have_css('.col-lg-6', count: 2)
      expect(page).to have_css('.col-md-6.col-lg-4', count: 3)
    end
  end

  scenario 'wizard' do
    visit '/dev/styleguide/wizard.html'
    expect(page).to have_content('Welcome to Tabler!')

  end
end
