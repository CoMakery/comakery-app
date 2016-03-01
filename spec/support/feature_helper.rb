module FeatureHelper
  def stub_slack
    WebMock.stub_request(:get, "http://127.0.0.1:61381/__identify__").
        # with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})
  end

  def xstep(title, &block)
    puts "PENDING STEP SKIPPED: #{title}" unless ENV["QUIET_TESTS"]
  end

  def step(title, &block)
    puts "STEP: #{title}" unless ENV["QUIET_TESTS"]
    block.call
  end

  def wut
    save_and_open_page
  end

  def login(account)
    page.set_rack_session(:account_id => account.id)
  end

end
