module FeatureHelper
  def wut
    save_and_open_page
  end

  def login(account)
    page.set_rack_session(account_id: account.id)
  end

  def logout
    page.set_rack_session(account_id: nil)
  end

  def ignore_js_errors
    yield
  rescue Capybara::Poltergeist::JavascriptError
    # ignore JS errors
  end
end
