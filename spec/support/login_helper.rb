RSpec.configure do |c|
  c.around(:each, :login) do |example|

    # account = create(:account)
    # create(:authentication, account_id: account.id)

    # visit "/take_action"
    #
    # click_link "Log in"
    #
    # page.all(".team").first.click
    #
    # page.all("button#oauth_authorizify").first.click

    example.call
  end
end
