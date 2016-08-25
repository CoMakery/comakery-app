module FeatureHelper
  def wut
    save_and_open_page
  end

  def login(account)
    page.set_rack_session(:account_id => account.id)
  end
end
